$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$audioDir = Join-Path $projectRoot 'audio'
$scriptPath = Join-Path $audioDir 'narration.txt'
$wavPath = Join-Path $audioDir 'eli_narration.wav'
$srtPath = Join-Path $audioDir 'eli_narration.srt'

Add-Type -AssemblyName System.Speech
$lines = @(Get-Content -LiteralPath $scriptPath | Where-Object { $_.Trim().Length -gt 0 } | ForEach-Object { $_.Trim() })
$fullText = $lines -join ' '
$starts = [System.Collections.Generic.List[int]]::new()
$cursor = 0
foreach ($line in $lines) {
    $starts.Add($cursor)
    $cursor += $line.Length + 1
}

$events = [System.Collections.Generic.List[object]]::new()
$synth = [System.Speech.Synthesis.SpeechSynthesizer]::new()
$voiceName = 'Microsoft David Desktop'
$synth.SelectVoice($voiceName)
$synth.Rate = -1
$synth.Volume = 94
$synth.SetOutputToWaveFile($wavPath)
$handler = {
    param($sender, $e)
    $events.Add([pscustomobject]@{
        CharacterPosition = [int]$e.CharacterPosition
        AudioPosition = [double]$e.AudioPosition.TotalSeconds
    })
}
$synth.add_SpeakProgress($handler)
$synth.Speak($fullText)
$synth.SetOutputToNull()
$synth.Dispose()

$firstWordByLine = @{}
foreach ($event in ($events | Sort-Object CharacterPosition)) {
    $lineIndex = -1
    for ($i = 0; $i -lt $starts.Count; $i++) {
        if ($event.CharacterPosition -ge $starts[$i]) { $lineIndex = $i }
        else { break }
    }
    if ($lineIndex -ge 0 -and -not $firstWordByLine.ContainsKey($lineIndex)) {
        $firstWordByLine[$lineIndex] = $event.AudioPosition
    }
}

function Format-SrtTime([double]$seconds) {
    $ms = [int][math]::Round($seconds * 1000)
    $hours = [math]::Floor($ms / 3600000)
    $ms %= 3600000
    $minutes = [math]::Floor($ms / 60000)
    $ms %= 60000
    $wholeSeconds = [math]::Floor($ms / 1000)
    $ms %= 1000
    return ('{0:00}:{1:00}:{2:00},{3:000}' -f $hours, $minutes, $wholeSeconds, $ms)
}

$reader = [System.IO.BinaryReader]::new([System.IO.File]::OpenRead($wavPath))
$reader.BaseStream.Position = 28
$bytesPerSecond = $reader.ReadInt32()
$reader.BaseStream.Position = 40
$dataBytes = $reader.ReadInt32()
$reader.Dispose()
$duration = $dataBytes / $bytesPerSecond

$subtitles = [System.Collections.Generic.List[string]]::new()
$subtitleIndex = 1
for ($i = 0; $i -lt $lines.Count; $i++) {
    if (-not $firstWordByLine.ContainsKey($i)) { continue }
    $begin = [double]$firstWordByLine[$i]
    $end = $duration
    for ($j = $i + 1; $j -lt $lines.Count; $j++) {
        if ($firstWordByLine.ContainsKey($j)) {
            $end = [math]::Max($begin + 0.7, [double]$firstWordByLine[$j] - 0.12)
            break
        }
    }
    $subtitles.Add("$subtitleIndex`n$(Format-SrtTime $begin) --> $(Format-SrtTime $end)`n$($lines[$i])")
    $subtitleIndex++
}

Set-Content -LiteralPath $srtPath -Value ($subtitles -join "`n`n") -Encoding utf8
Write-Host "Narration voice: $voiceName (Windows SAPI, rate -1)"
Write-Host "Narration duration: $([math]::Round($duration, 2)) seconds"
Write-Host "Subtitle cues: $($subtitles.Count)"
Write-Host "WAV: $wavPath"
Write-Host "SRT: $srtPath"

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Speech
$episode = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$script = Join-Path $episode 'story\late-morning-episode-02.md'
$reads = @(Get-Content -LiteralPath $script -Encoding UTF8 | Where-Object { $_.StartsWith('**Daniel:** ') } | ForEach-Object { $_.Substring(12) })
if ($reads.Count -ne 6) { throw "Expected six narration beats, found $($reads.Count)." }
$audioFolder = Join-Path $PSScriptRoot 'audio'
New-Item -Path $audioFolder -ItemType Directory -Force | Out-Null
$synth = [System.Speech.Synthesis.SpeechSynthesizer]::new()
try {
    $synth.SelectVoice('Microsoft David Desktop')
    $synth.Rate = 0
    $synth.Volume = 94
    for ($i = 0; $i -lt $reads.Count; $i++) {
        $target = Join-Path $audioFolder ('beat_{0:00}.wav' -f ($i+1))
        $synth.SetOutputToWaveFile($target)
        $synth.Speak($reads[$i])
        $synth.SetOutputToNull()
    }
} finally {
    $synth.Dispose()
}

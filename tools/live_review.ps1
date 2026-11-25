Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[Windows.Forms.Application]::EnableVisualStyles()

$workspace = Split-Path -Parent $PSScriptRoot
$review = Join-Path $workspace 'godot/line_13/render/.live-review'
$defaultPreview = Join-Path $workspace 'assets/houses/houses_preview.png'
$statusPath = Join-Path $review 'status.json'
$notesPath = Join-Path $review 'review-notes.txt'
New-Item -ItemType Directory -Force $review | Out-Null

$form = New-Object Windows.Forms.Form
$form.Text = 'LINE 13 | Live review'
$form.ClientSize = [Drawing.Size]::new(1000, 740)
$form.MinimumSize = [Drawing.Size]::new(620, 480)
$form.StartPosition = 'CenterScreen'
$form.Font = [Drawing.Font]::new('Segoe UI', 10)

$layout = New-Object Windows.Forms.TableLayoutPanel
$layout.Padding = [Windows.Forms.Padding]::new(18)
$layout.Dock = 'Fill'
$layout.ColumnCount = 1
$layout.RowCount = 7
foreach ($height in 42, 45, 0, 26, 12, 74, 38) {
    $row = if ($height) {
        [Windows.Forms.RowStyle]::new('Absolute', $height)
    } else {
        [Windows.Forms.RowStyle]::new('Percent', 100)
    }
    [void]$layout.RowStyles.Add($row)
}
$form.Controls.Add($layout)

$stage = New-Object Windows.Forms.Label
$stage.Font = [Drawing.Font]::new('Segoe UI', 21, [Drawing.FontStyle]::Bold)
$detail = New-Object Windows.Forms.Label
$preview = New-Object Windows.Forms.PictureBox
$preview.SizeMode = 'Zoom'
$preview.BackColor = [Drawing.Color]::FromArgb(24, 32, 39)
$timestamp = New-Object Windows.Forms.Label
$progress = New-Object Windows.Forms.ProgressBar
$note = New-Object Windows.Forms.TextBox
$note.Multiline = $true
$note.ScrollBars = 'Vertical'
$note.AccessibleName = 'Review note'
$actions = New-Object Windows.Forms.FlowLayoutPanel

$controls = @($stage, $detail, $preview, $timestamp, $progress, $note, $actions)
for ($i = 0; $i -lt $controls.Count; $i++) {
    $controls[$i].Dock = 'Fill'
    $layout.Controls.Add($controls[$i], 0, $i)
}

$save = New-Object Windows.Forms.Button
$save.Text = 'Save review note'
$save.AutoSize = $true
$folder = New-Object Windows.Forms.Button
$folder.Text = 'Open review folder'
$folder.AutoSize = $true
$feedback = New-Object Windows.Forms.Label
$feedback.AutoSize = $true
$actions.Controls.AddRange(@($save, $folder, $feedback))
$folder.Add_Click({ Invoke-Item -LiteralPath $review })
$save.Add_Click({
    $content = $note.Text.Trim()
    if (-not $content) {
        $feedback.Text = 'Write a note first.'
        return
    }
    try {
        $entry = '[{0}] {1} | {2}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $stage.Text, $timestamp.Text
        Add-Content -Encoding UTF8 -LiteralPath $notesPath -Value "$entry`r`n$content`r`n" -ErrorAction Stop
        $note.Clear()
        $feedback.Text = 'Note saved'
    } catch {
        $feedback.Text = 'Could not save the note.'
    }
})

$script:imageKey = ''
function Update-Review {
    $update = if (Test-Path -LiteralPath $statusPath) {
        Get-Content -LiteralPath $statusPath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
    }
    $stage.Text = if ($update.stage) { $update.stage } else { 'House asset review' }
    $detail.Text = if ($update.detail) { $update.detail } else { 'Latest Sand3D draft. Godot frames appear during a review render.' }
    $path = if ($update.image) { $update.image } else { $defaultPreview }
    $timestamp.Text = 'Latest asset preview'
    $percent = 0
    if ($update.run) {
        $frames = Join-Path $review $update.run
        $latest = Get-ChildItem -LiteralPath $frames -Filter 'frame-*.png' -File -ErrorAction SilentlyContinue |
            Sort-Object Name -Descending | Select-Object -First 1
        if ($latest -and $latest.BaseName -match '^frame-(\d+)$') {
            $seconds = [int]$Matches[1] / 1000.0
            $timestamp.Text = 'Godot scene time  {0:F1}s' -f $seconds
            $path = $latest.FullName
            if ($update.duration) { $percent = [math]::Min(100, 100 * $seconds / $update.duration) }
        } else {
            $timestamp.Text = 'Waiting for the first Godot frame'
        }
        if ($stage.Text -like '* ready') { $percent = 100 }
    }
    $progress.Value = [int]$percent

    if (Test-Path -LiteralPath $path) {
        $file = Get-Item -LiteralPath $path -ErrorAction Stop
        $key = "$path|$($file.LastWriteTimeUtc.Ticks)"
        if ($key -ne $script:imageKey) {
            $stream = [IO.MemoryStream]::new([IO.File]::ReadAllBytes($path))
            try {
                $source = [Drawing.Image]::FromStream($stream)
                try { $image = [Drawing.Bitmap]::new($source) } finally { $source.Dispose() }
            } finally { $stream.Dispose() }
            $previous = $preview.Image
            $preview.Image = $image
            if ($previous) { $previous.Dispose() }
            $script:imageKey = $key
            Set-Content -LiteralPath (Join-Path $review 'viewer-state.json') -Encoding UTF8 -Value (@{
                process = $PID
                stage = $stage.Text
                preview = $path
                timestamp = $timestamp.Text
            } | ConvertTo-Json -Compress)
        }
    }
}
$timer = New-Object Windows.Forms.Timer
$timer.Interval = 400
$timer.Add_Tick({
    try { Update-Review } catch { <# Retry if a file is being replaced. #> }
})
$form.Add_Shown({
    $form.Activate()
    $timer.Start()
})
$form.Add_FormClosed({
    $timer.Dispose()
    if ($preview.Image) { $preview.Image.Dispose() }
})
[void]$form.ShowDialog()



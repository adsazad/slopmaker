$ErrorActionPreference = 'Stop'
$workspace = $PSScriptRoot
$venvPython = Join-Path $workspace '.venv\Scripts\python.exe'
$cloudflaredPath = Join-Path $workspace 'bin\cloudflared.exe'

Push-Location $workspace
try {
    if (-not (Test-Path -LiteralPath $venvPython)) {
        $pyLauncher = Get-Command py -ErrorAction SilentlyContinue
        $pythonCommand = Get-Command python -ErrorAction SilentlyContinue

        if ($pyLauncher) {
            & $pyLauncher.Source -3.12 -m venv (Join-Path $workspace '.venv')
            if ($LASTEXITCODE -ne 0) {
                throw 'Python 3.12 was not found. Install Python 3.12 from https://www.python.org/downloads/windows/ and run this launcher again.'
            }
        } elseif ($pythonCommand) {
            $version = & $pythonCommand.Source --version 2>&1
            if ($version -notmatch 'Python 3\.(11|12|13)\.') {
                throw 'Install Python 3.11, 3.12, or 3.13 from https://www.python.org/downloads/windows/, then run this launcher again.'
            }
            & $pythonCommand.Source -m venv (Join-Path $workspace '.venv')
            if ($LASTEXITCODE -ne 0) { throw 'Could not create the Python environment.' }
        } else {
            throw 'Python 3.11 or newer is required. Install it from https://www.python.org/downloads/windows/ and run this launcher again.'
        }
    }

    if (-not (Test-Path -LiteralPath $cloudflaredPath)) {
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $cloudflaredPath) | Out-Null
        Write-Host 'Downloading cloudflared from Cloudflare official releases…'
        Invoke-WebRequest `
            -Uri 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe' `
            -OutFile $cloudflaredPath
    }

    Write-Host 'Installing the Qwen3-TTS app dependencies (first run only)…'
    & $venvPython -m pip install --upgrade pip
    if ($LASTEXITCODE -ne 0) { throw 'Could not update pip.' }
    & $venvPython -m pip install -r (Join-Path $workspace 'requirements.txt')
    if ($LASTEXITCODE -ne 0) { throw 'Could not install the app dependencies.' }

    $env:QWEN_CLOUDFLARED_BIN = $cloudflaredPath
    & $venvPython (Join-Path $workspace 'app.py')
    if ($LASTEXITCODE -ne 0) { throw 'The voice studio stopped with an error.' }
} finally {
    Pop-Location
}

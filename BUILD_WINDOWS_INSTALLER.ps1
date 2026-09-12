$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

function Need([string]$name, [string]$command) {
  if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
    throw "$name is required but was not found in PATH."
  }
}

Need 'Node.js' 'node'
Need 'npm' 'npm'
Need 'Python 3.11+' 'python'

Write-Host '=== Hamraz Windows Installer Builder ===' -ForegroundColor Cyan

Write-Host '[1/5] Building Web UI...'
Push-Location (Join-Path $Root 'frontend')
npm install --no-audit --no-fund
npm run build
Pop-Location
$Dist = Join-Path $Root 'frontend\dist'
if (-not (Test-Path (Join-Path $Dist 'index.html'))) { throw 'frontend/dist/index.html was not produced.' }

Write-Host '[2/5] Preparing desktop renderer...'
$Desktop = Join-Path $Root 'apps\hamraz_desktop'
$Renderer = Join-Path $Desktop 'frontend-dist'
if (Test-Path $Renderer) { Remove-Item $Renderer -Recurse -Force }
Copy-Item $Dist $Renderer -Recurse -Force

Write-Host '[3/5] Packaging local Hamraz server...'
$Backend = Join-Path $Root 'backend'
Push-Location $Backend
python -m pip install -r requirements.txt
python -m pip install pyinstaller
python -m PyInstaller --noconfirm --clean HamrazServer.spec
Pop-Location
$ServerDist = Join-Path $Backend 'dist\HamrazServer'
if (-not (Test-Path (Join-Path $ServerDist 'HamrazServer.exe'))) { throw 'HamrazServer.exe was not produced.' }
$BackendBundle = Join-Path $Desktop 'backend-dist'
if (Test-Path $BackendBundle) { Remove-Item $BackendBundle -Recurse -Force }
Copy-Item $ServerDist $BackendBundle -Recurse -Force

Write-Host '[4/5] Building Windows installer...'
Push-Location $Desktop
npm install --no-audit --no-fund
npm run package
Pop-Location

Write-Host '[5/5] Copying release artifacts...'
$BuilderOut = Join-Path $Desktop 'dist'
$Release = Join-Path $Root 'release'
New-Item -ItemType Directory -Path $Release -Force | Out-Null
Get-ChildItem $BuilderOut -Filter '*.exe' -File | ForEach-Object { Copy-Item $_.FullName $Release -Force }

Write-Host ''
Write-Host 'HAMRAZ WINDOWS RELEASE READY' -ForegroundColor Green
Get-ChildItem $Release -Filter '*.exe' -File | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize

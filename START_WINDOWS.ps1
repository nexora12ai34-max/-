$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'HAMRAZ_ONE_CLICK_BUILD.ps1') -Target Menu

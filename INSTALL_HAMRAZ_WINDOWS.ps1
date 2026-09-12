$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Version = (Get-Content (Join-Path $Root 'VERSION') -Raw).Trim()
$SetupPath = Join-Path $Root "release\Hamraz-$Version-Setup-x64.exe"
if (-not (Test-Path -LiteralPath $SetupPath)) {
  throw "Hamraz installer was not found: $SetupPath. Build Windows first with HAMRAZ_ONE_CLICK_BUILD.ps1 -Target Windows."
}
Start-Process -FilePath $SetupPath -Wait

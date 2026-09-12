$ErrorActionPreference='Stop'; Set-StrictMode -Version Latest
$Root=Resolve-Path (Join-Path $PSScriptRoot '..')
foreach($dir in @('frontend','apps\hamraz_admin_web','apps\hamraz_desktop')) { Push-Location (Join-Path $Root $dir); npm install --package-lock-only --ignore-scripts --no-audit --no-fund; Pop-Location }

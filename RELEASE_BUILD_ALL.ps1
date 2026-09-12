$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$Root=Resolve-Path $PSScriptRoot
Set-Location $Root
Write-Host '=== Hamraz full release verification ===' -ForegroundColor Cyan
if ([string]::IsNullOrWhiteSpace($env:HAMRAZ_RELEASE_API_URL) -or $env:HAMRAZ_RELEASE_API_URL -notmatch '^https://') { throw 'HAMRAZ_RELEASE_API_URL must be an HTTPS URL for Android release builds.' }
python scripts_release_check.py
python -m compileall -q backend/app
python -m pytest -q
Push-Location frontend
if(-not(Test-Path package-lock.json)){throw 'frontend/package-lock.json missing'}
npm ci --no-audit --no-fund
npm run build
Pop-Location
Push-Location apps/hamraz_admin_web
if(-not(Test-Path package-lock.json)){throw 'admin package-lock.json missing'}
npm ci --no-audit --no-fund
npm run build
Pop-Location
Push-Location apps/hamraz_flutter
flutter pub get
flutter analyze
flutter test
flutter build apk --release --dart-define=API_URL=$env:HAMRAZ_RELEASE_API_URL
flutter build appbundle --release --dart-define=API_URL=$env:HAMRAZ_RELEASE_API_URL
Pop-Location
& "$Root/scripts/release/build_windows.ps1"
& "$Root/scripts/release/make_checksums.ps1"
Write-Host '=== Hamraz full release verification completed ===' -ForegroundColor Green

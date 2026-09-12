$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root
function Need($name,$cmd){ if(-not (Get-Command $cmd -ErrorAction SilentlyContinue)){ throw "$name is required." } }
Need 'Python' 'python'; Need 'Node.js' 'node'; Need 'npm' 'npm'; Need 'Flutter' 'flutter'
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install --upgrade pip
.\.venv\Scripts\python.exe -m pip install -r backend\requirements.txt
foreach($dir in @('frontend','apps\hamraz_admin_web','apps\hamraz_desktop')){
  Push-Location $dir
  if(Test-Path package-lock.json){ npm ci --no-audit --no-fund }
  else { throw "$dir\package-lock.json is missing. Generate and commit it before release." }
  Pop-Location
}
Push-Location apps\hamraz_flutter
flutter pub get
Pop-Location
Write-Host 'Hamraz dependencies installed/validated.' -ForegroundColor Green

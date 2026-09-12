# Hamraz Build Prerequisites

## Required versions
- Node.js 22.x
- npm 10.x
- Python 3.11+
- Flutter SDK (Dart 3.8+ compatible)
- Android SDK + Build Tools + JDK 17/21
- Windows 10/11 + PowerShell 7+ for signed Windows packaging

## Backend
Run from repository root:
```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install --upgrade pip
.\.venv\Scripts\python.exe -m pip install -r backend/requirements.txt
```
Required runtime packages include FastAPI, SQLAlchemy, python-jose[cryptography], passlib, psycopg[binary], pydantic-settings, google-auth, redis, Pillow and cryptography.

## Web/Admin/Desktop Node dependencies
For each directory:
- `frontend`
- `apps/hamraz_admin_web`
- `apps/hamraz_desktop`

A release build requires a committed `package-lock.json` and uses:
```powershell
npm ci
```
Do not substitute `npm install` in CI.

## Android
```powershell
cd apps/hamraz_flutter
flutter pub get
flutter analyze
flutter test
flutter build apk --release --dart-define=API_URL=https://YOUR_API_HOST
flutter build appbundle --release --dart-define=API_URL=https://YOUR_API_HOST
```
Release builds must not use `10.0.2.2`, localhost HTTP, or a debug signing configuration.

## Windows packaging
Windows production packaging requires Node/npm, Python, PyInstaller, PowerShell 7+, Electron Builder and the frontend/backend dependencies. Run:
```powershell
.\scripts\release\build_windows.ps1
```
The script fails closed if lockfiles or EXE artifacts are missing.

## Environment
Production must provide real values for:
- `APP_ENV=production`
- `JWT_SECRET` (32+ random bytes)
- `SESSION_SECRET` where applicable
- PostgreSQL/Redis connection settings
- `CORS_ORIGINS`
- HTTPS `PUBLIC_BASE_URL`
- Storage credentials
- AI provider credentials when AI is enabled
- TURN credentials when calls require TURN

Never commit real secrets.

## One-command setup
Windows:
```powershell
./INSTALL_ALL_DEPENDENCIES.ps1
```
Linux/macOS:
```bash
./INSTALL_ALL_DEPENDENCIES.sh
```

The installer validates toolchains and installs backend/Flutter/Node dependencies. It also reports any missing npm lockfile so the release build cannot accidentally become non-reproducible.

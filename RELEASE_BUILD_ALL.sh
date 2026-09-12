#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"
: "${HAMRAZ_RELEASE_API_URL:?Set HAMRAZ_RELEASE_API_URL=https://... before release build}"
python3 scripts_release_check.py
python3 -m compileall -q backend/app
python3 -m pytest -q
for dir in frontend apps/hamraz_admin_web; do
  test -f "$dir/package-lock.json" || { echo "Missing $dir/package-lock.json"; exit 1; }
  (cd "$dir" && npm ci --no-audit --no-fund && npm run build)
done
(cd apps/hamraz_flutter && flutter pub get && flutter analyze && flutter test && flutter build apk --release --dart-define=API_URL="$HAMRAZ_RELEASE_API_URL" && flutter build appbundle --release --dart-define=API_URL="$HAMRAZ_RELEASE_API_URL")
echo 'Run scripts/release/build_windows.ps1 on Windows for signed Windows artifacts.'

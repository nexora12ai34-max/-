#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"
command -v python3 >/dev/null || { echo 'Python 3 is required'; exit 1; }
command -v node >/dev/null || { echo 'Node.js is required'; exit 1; }
command -v npm >/dev/null || { echo 'npm is required'; exit 1; }
command -v flutter >/dev/null || { echo 'Flutter is required'; exit 1; }
python3 -m venv .venv
.venv/bin/python -m pip install --upgrade pip
.venv/bin/python -m pip install -r backend/requirements.txt
for dir in frontend apps/hamraz_admin_web apps/hamraz_desktop; do
  if [[ -f "$dir/package-lock.json" ]]; then (cd "$dir" && npm ci --no-audit --no-fund); else echo "ERROR: $dir/package-lock.json missing" >&2; exit 1; fi
done
(cd apps/hamraz_flutter && flutter pub get)
echo 'Hamraz dependencies installed/validated.'

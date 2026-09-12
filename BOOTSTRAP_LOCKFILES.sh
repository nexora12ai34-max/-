#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
for dir in frontend apps/hamraz_admin_web apps/hamraz_desktop; do
  (cd "$ROOT/$dir" && npm install --package-lock-only --ignore-scripts --no-audit --no-fund && npm ci --ignore-scripts --no-audit --no-fund)
done

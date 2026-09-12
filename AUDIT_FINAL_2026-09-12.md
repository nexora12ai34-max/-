# Hamraz final local audit

Audit scope: repository source, backend tests, Python syntax, shell syntax, JSON syntax, security scan, runtime wiring, source completeness, clean-room release audit, Windows one-click builder and user-facing launch helpers.

## Verified in this environment

- Backend tests: 104 passed, 2 skipped because optional runtime packages were not installed in this environment.
- Python compile: passed.
- Security scan: 0 violations.
- Runtime wiring audit: 0 orphan routers, 0 duplicate exact routes.
- Release audit: 0 errors, 0 warnings.
- Source completeness: 0 missing required files.
- Clean-room audit after cleanup: 0 errors.
- JSON parsing: passed.
- Shell syntax (`bash -n`): passed for all repository `.sh` files.
- Builder source: PowerShell parser validation is built into the builder and executes on Windows.

## Fixes made in this final pass

- One-click installer no longer uses the reserved PowerShell `$Args` name for command arguments.
- The builder now validates its own PowerShell syntax on the target Windows machine.
- The builder now validates critical project files before packaging.
- Flutter installed in the local builder cache is recognized even when it is not yet on PATH.
- Android release packaging requires an HTTPS API URL.
- Windows packaging requires the backend executable and both expected versioned EXE outputs.
- `-Target All` now fails at the end when any requested stage failed instead of reporting false success.
- Windows installer launcher now resolves the actual versioned Setup EXE instead of a stale hard-coded filename.
- Added `RUN_HAMRAZ.bat` for double-clicking into the one-click menu.
- Updated `START_WINDOWS.ps1` to use the one-click menu.
- Updated `.gitignore` for generated caches/build folders.
- Final package was cleaned of generated Python caches and pytest cache.

## External prerequisites that cannot be truthfully embedded

Real npm package-lock files must be generated from the package registry on the user's/networked machine. Real Android and Windows native release artifacts require their respective toolchains, SDKs, certificates/keystores and, for production, real server/API infrastructure. No fake artifact is included.

## Session fix — Electron/Windows packaging

- `apps/hamraz_desktop/electron-builder.yml` had `forceCodeSigning: true`, which makes `npm run package` hard-fail for anyone who doesn't already own a paid Windows code-signing certificate. Removed the forced flag. electron-builder still signs automatically the moment `CSC_LINK`/`CSC_KEY_PASSWORD` are set in the environment, so real signing keeps working once a certificate exists — it's just no longer a blocker for producing a first, unsigned `.exe` (Windows SmartScreen will warn on an unsigned app; that's expected and not a bug).
- Verified this session, offline (no network/Flutter/Android SDK available in this environment): backend Python (8628 lines) compiles cleanly, all shell scripts pass `bash -n`, all JSON parses, no hardcoded secrets/TODOs/debug prints found. Could not run `pytest`, `npm`, or `flutter build` here — those need the real toolchain + internet on the user's machine (see README "وضعیت release" section, still accurate).

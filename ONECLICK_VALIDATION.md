# Hamraz One-Click Builder — Final Validation

Date: 2026-09-12

## Checked in this environment

- `HAMRAZ_ONE_CLICK_BUILD.ps1` is exactly 5,000 lines.
- The previous `returnDoctor` parser/runtime typo is absent.
- The previous checksum-expression parser hazard was rewritten into simple statements.
- Basic PowerShell lexical delimiter validation passed: parentheses, brackets, braces, and quoted strings are balanced.
- All 13 PowerShell scripts in the project passed the same structural delimiter validation.
- The builder has explicit targets: Menu, Doctor, Install, Verify, Web, Windows, Android, All, Clean.
- The builder never claims an APK/AAB/EXE exists unless the expected artifact file exists.
- Build logs, state, reports and release artifacts are kept under project-local directories.
- Windows/Android signing is not silently bypassed.
- Winget installation refreshes the current process PATH before subsequent checks.
- SHA-256 generation uses a simple, unambiguous PowerShell expression.

## Important limitation

This Linux execution environment does not contain Windows PowerShell 5.1, Visual Studio Build Tools, Flutter/Android SDK, or a Windows Electron packaging environment. Therefore a native Windows parser/build run cannot honestly be claimed here. The final file is structured to be executed on the user's Windows machine and fails closed when required native tools are unavailable.

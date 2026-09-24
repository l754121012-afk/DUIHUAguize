---
name: windows-powershell
description: Safe Windows and PowerShell execution rules for Codex tasks, including non-admin environments, background processes, path validation, and destructive-operation guards.
---

# Windows / PowerShell Adapter

## Safety

- Before recursive delete or move, resolve absolute paths and verify they remain inside the intended workspace.
- Use one shell end to end; do not enumerate in PowerShell and delete through another shell.
- Prefer native PowerShell cmdlets such as `Remove-Item` and `Move-Item` with literal paths.
- Use `Start-Process -WindowStyle Hidden` for background helpers unless the user needs a visible window.
- Do not leave background servers running after verification.

## Verification

- Report exit codes, not only printed text.
- Capture only the relevant final lines for long test output.
- When long-running processes are needed, poll the session and close it before final response.

## Local proxy diagnostics

For Git/GitHub or other remote failures, check stale proxy settings before changing remote URLs or credentials.

Read `references/local-proxy-diagnostics.md`.

# Adapter Registry

Adapters extend Core only when their trigger matches or the user explicitly loads them.

| Adapter | Load | Triggers | Scope | Remote / side effects |
|---|---|---|---|---|
| `model-routing/deepseek-cc-switch` | auto/manual | DeepSeek, CC Switch, model routing, token price, cache pricing | text/config | may edit CC Switch DB when explicitly run |
| `visual/dual-thread` | auto/manual | image, screenshot, visual review, OCR, pixel diff, screenshot-heavy task | files/vision session | calls vision provider only through preprocess script |
| `engine/godot` | auto/manual | Godot, scene, resource, headless test, GDScript | repo/toolchain | runs Godot binaries |
| `platform/windows-powershell` | auto/manual | PowerShell, Windows, non-admin, Start-Process, path safety | shell | read/write inside requested paths |
| `runtime/codex-app` | auto/manual | Codex App, automation, artifact, inline comment, open in app | app runtime | app-specific UI actions |
| `files/artifacts` | auto/manual | docx, pptx, xlsx, csv, pdf, slides, sheets | artifacts | invokes bundled artifact skills |
| `git/worktree-handoff` | auto/manual | dirty worktree, commit, push, PR, handoff, continuation | git | may create commit/PR only when requested |

## Load priority

1. Core.
2. Default profile.
3. Auto-triggered adapters.
4. Manual adapters explicitly requested by the user.

If adapters conflict, project rules win over adapters; Core safety rules win over everything.


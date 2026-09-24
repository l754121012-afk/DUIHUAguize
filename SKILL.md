---
name: agent-collaboration-protocol
description: Universal Codex collaboration protocol with Task Preflight, same-class audits, context governance, concise reporting, and optional adapters for DeepSeek/CC Switch, visual review, Godot, Windows, Codex App, artifacts, and Git.
---

# Agent Collaboration Protocol

Read and follow `core/SKILL.md`.

Load `profiles/default/` unless the user selects another profile.

Route optional capabilities through `adapters/registry.md`:

- DeepSeek or CC Switch: `adapters/model-routing/deepseek-cc-switch/SKILL.md`
- images or visual review: `adapters/visual/dual-thread/SKILL.md`
- Godot: `adapters/engine/godot/SKILL.md`
- Windows or PowerShell: `adapters/platform/windows-powershell/SKILL.md`
- Codex App runtime: `adapters/runtime/codex-app/SKILL.md`
- document, slide, spreadsheet or PDF output: `adapters/files/artifacts/SKILL.md`
- Git, dirty worktree, PR or handoff: `adapters/git/worktree-handoff/SKILL.md`

Do not load an adapter unless its trigger matches or the user requests it.


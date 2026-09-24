---
name: godot-verification
description: Generic Godot project workflow for GDScript, scenes, resources, imports, headless tests, and warning-as-error validation. Use whenever a task involves Godot.
---

# Godot Adapter

## Default validation order

1. Read project `AGENTS.md` and handoff.
2. Locate the main scene and test scripts.
3. Run the smallest relevant headless test.
4. Run the full project test set if the change touches shared behavior.
5. If parity exists, run the project-specific parity suite.

Generic command shape:

```powershell
<godot-console> --headless --path . --script res://tools/selftest.gd
<godot-console> --headless --path . res://scenes/main.tscn -- --smoke
```

## Rules

- Treat warnings-as-errors as real compile failures.
- Avoid broad scene reimports unless required.
- Verify generated `.uid` and `.import` changes are intentional.
- Run resource/scene validation before claiming a UI or scene change is complete.
- Keep engine-specific paths and executable locations in project rules, not Core.


# Security and Safety

- Never expose or commit secrets.
- Treat repositories as potentially dirty; never reset or revert user changes.
- Before recursive delete or move, resolve the absolute target and verify it is inside the intended directory.
- Do not run destructive git commands unless the user explicitly requests them.
- State when an adapter performs remote calls or writes outside the project.


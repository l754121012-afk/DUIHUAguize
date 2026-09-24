---
name: git-worktree-handoff
description: Safe Git collaboration for dirty worktrees, handoffs, commits, pushes, pull requests, and continuation across Codex tasks.
---

# Git Worktree And Handoff Adapter

## Safety

- Inspect `git status` before editing.
- Never reset, checkout or revert user changes unless explicitly requested.
- Keep unrelated dirty files untouched.
- Stage only files owned by the current deliverable.
- Do not push when authentication or remote state is uncertain.

## Handoff

Before ending a long task, record:

- goal and status;
- changed files;
- verification commands and outcomes;
- current branch and remote state;
- blockers and next step;
- paste-ready continuation prompt.

## Pull requests

Attach every created PR to the current task and include verification evidence in the PR body.

## Remote push failures

When GitHub push fails:

1. Read the current proxy configuration.
2. Test whether the configured proxy port is actually listening.
3. Try direct connection once.
4. Try known local helper ports and identify the owning process.
5. Use the working proxy only as a command-level override first.
6. Push, then verify the remote commit with `ls-remote`.

Read `references/remote-push-troubleshooting.md`.

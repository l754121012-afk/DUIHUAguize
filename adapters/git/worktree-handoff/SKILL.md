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


# Context Governance

## Read order

1. Project `AGENTS.md`.
2. Session handoff.
3. Index, parity matrix or architecture map.
4. Smallest relevant source slice.

## Rules

- Do not start with a repository-wide read.
- Prefer `rg`, indexes, test output and diffs over opening large files.
- Keep tool output bounded.
- Put durable facts in project files, not only in conversation.
- Maintain zero-image main sessions when the visual adapter is active.
- On compaction, stop the milestone, update handoff and resume in a fresh task.


# Default Profile

This profile is user-specific and may be replaced without changing Core.

## Language

- User-facing replies: concise Chinese.
- Internal working notes/reasoning: English is allowed for token efficiency.
- Durable facts and handoffs: Chinese.

## Work rhythm

- For S tasks, execute directly unless risk is non-trivial.
- For M+ tasks, start with a short Task Preflight.
- Do not ask for “continue” after every step; keep working until the requested outcome is complete.
- Ask only when a real decision changes implementation direction.
- When options are necessary, number them.

## Reporting

- Progress update: one or two sentences.
- Final report: changes, verification, expected vs actual token/cost, same-class audit, unresolved items.
- Prefer quantified evidence, parameter changes and command results.
- Avoid long explanations unless the user asks for reasoning.

## Context and cost

- Prefer handoff/index first and minimal local reads.
- Avoid repository-wide reads unless evidence requires it.
- Track token estimates and use provider adapters for model-specific prices.
- Every non-trivial task must show both the Task Preflight cost estimate and the completion cost
  verification; missing either side is treated as an incomplete report.
- If compaction occurs, stop the milestone and hand off.

## Autonomy

- Resolve the task end to end.
- Preserve user changes in dirty worktrees.
- Do not revert files not owned by the current task.
- Use the same-class audit after fixing a pattern.

## Local network profile

- Existing global Git proxy settings may be stale.
- In the current Windows environment, the Vortex helper commonly listens on `127.0.0.1:7897`.
- A stale `127.0.0.1:7890` setting has previously existed and may fail when no process is listening.
- Treat these as environment hints, not Core rules. Verify the active port before using it.

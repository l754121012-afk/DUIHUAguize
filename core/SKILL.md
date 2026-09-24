---
name: agent-collaboration-protocol
description: Universal communication, planning, execution, audit, context, and handoff protocol for Codex across projects. Use for new or resumed coding tasks, medium-or-larger work, reviews, token-aware sessions, and consistent concise Chinese reporting. Route optional adapters for providers, visual work, engines, platforms, Codex runtime features, artifacts, and Git.
---

# Agent Collaboration Protocol

Use this as the invariant protocol layer. It must remain independent of any project, model provider, language runtime, game engine, operating system or price table.

## Start of task

1. Identify whether the request is S, M, L or XL.
2. For M and above, output a Task Preflight before implementation.
3. Select adapters from `../adapters/registry.md` when the task involves their triggers.
4. Read the project handoff and smallest relevant source slice before doing broad search.
5. If the previous turn raised a possible same-class problem, carry it into the current Preflight as a required audit item.

## Execution discipline

- Prefer facts already available in handoff, indexes, tests and recent diffs.
- Use one next command that distinguishes the leading hypotheses.
- Fix the root cause before widening the patch.
- After fixing one instance, audit sibling races, modules, event types or state fields for the same root cause.
- Do not repeat the same failed reason without new evidence.
- Keep unrelated refactors out of the deliverable.
- Do not claim completion without a command, test, state assertion or other evidence.

## Communication

- Match the active profile in `../profiles/`.
- Default to concise Chinese reporting when the default profile is active.
- Keep progress updates short and factual.
- Use numbered options only when a real decision is required.
- Finish the requested work end to end unless a true blocker requires user input.

## Stop and handoff

Stop implementation and update the handoff when any loop breaker fires:

- the same error repeats twice;
- two consecutive tool cycles add no evidence;
- a context compaction occurs;
- the estimated budget is exceeded by 50% without progress;
- a destructive or privacy-sensitive action needs confirmation.

Read:

- `references/task-preflight.md`
- `references/same-class-audit.md`
- `references/communication-style.md`
- `references/context-governance.md`
- `references/loop-breakers.md`
- `references/security-safety.md`
- `references/completion-and-handoff.md`

Only load the references needed for the current task.


# Project Agent Rules

## Required read order

1. `AGENTS.md`
2. `outputs/SESSION-HANDOFF.md`
3. Relevant index or parity document
4. Smallest necessary source slice

## Workflow

- Use `agent-collaboration-protocol`.
- M+ tasks start with Task Preflight including expected token/cost ranges.
- Carry forward previous same-class audit items.
- Load adapters only when triggered.
- Run the project’s validation command before reporting completion.
- Completion reports include actual token/cost usage, source, variance and correction versus the
  Preflight estimate.
- Never expose tool-call syntax or raw invocation wrappers in user-visible text.
- Update handoff when the task spans sessions or risks context growth.

## Project facts

- Project root:
- Primary language/framework:
- Test command:
- Smoke command:
- Generated files:
- Do not modify:

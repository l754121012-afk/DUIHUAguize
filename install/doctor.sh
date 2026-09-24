#!/usr/bin/env sh
set -eu

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SKILLS_DIR="$CODEX_HOME/skills"
failed=0

for name in \
  agent-collaboration-protocol \
  deepseek-cc-switch \
  dual-thread-vision-workflow \
  godot-verification \
  windows-powershell \
  codex-app-runtime \
  artifact-router \
  git-worktree-handoff
do
  if [ -f "$SKILLS_DIR/$name/SKILL.md" ]; then
    echo "OK   $name"
  else
    echo "MISS $name"
    failed=1
  fi
done

if [ -f "$CODEX_HOME/AGENTS.md" ] && grep -q "agent-collaboration-protocol:start" "$CODEX_HOME/AGENTS.md"; then
  echo "OK   global AGENTS bootstrap"
else
  echo "MISS global AGENTS bootstrap"
  failed=1
fi

if [ "$failed" -ne 0 ]; then
  exit 1
fi
echo "Doctor: PASS"


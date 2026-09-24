#!/usr/bin/env sh
set -eu

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SKILLS_DIR="$(cd "$CODEX_HOME/skills" && pwd)"

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
  target="$SKILLS_DIR/$name"
  case "$target" in
    "$SKILLS_DIR"/*)
      if [ -e "$target" ]; then
        rm -rf "$target"
        echo "Removed: $name"
      fi
      ;;
    *)
      echo "Refusing to remove path outside skills directory: $target" >&2
      exit 1
      ;;
  esac
done

AGENTS_PATH="$CODEX_HOME/AGENTS.md"
if [ -f "$AGENTS_PATH" ]; then
  TMP_AGENTS="$AGENTS_PATH.tmp-$$"
  awk '
    /agent-collaboration-protocol:start/ { skip=1; next }
    /agent-collaboration-protocol:end/ { skip=0; next }
    !skip { print }
  ' "$AGENTS_PATH" > "$TMP_AGENTS"
  mv "$TMP_AGENTS" "$AGENTS_PATH"
fi

echo "Uninstall complete."


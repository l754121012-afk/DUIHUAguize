#!/usr/bin/env sh
set -eu

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$CODEX_HOME/skills"
MAIN_TARGET="$SKILLS_DIR/agent-collaboration-protocol"
STAMP="$(date +%Y%m%d-%H%M%S)"
FORCE="${FORCE:-0}"

backup_existing() {
  target="$1"
  if [ -e "$target" ]; then
    if [ "$FORCE" != "1" ]; then
      echo "Target exists: $target. Set FORCE=1 to back it up and replace it." >&2
      exit 1
    fi
    mv "$target" "$target.backup-$STAMP"
    echo "Backed up: $target"
  fi
}

mkdir -p "$SKILLS_DIR"
backup_existing "$MAIN_TARGET"
mkdir -p "$MAIN_TARGET"

for item in SKILL.md README.md VERSION SECURITY.md core profiles adapters templates; do
  cp -R "$REPO_ROOT/$item" "$MAIN_TARGET/"
done

install_adapter() {
  name="$1"
  relative="$2"
  target="$SKILLS_DIR/$name"
  backup_existing "$target"
  cp -R "$MAIN_TARGET/$relative" "$target"
  echo "Installed adapter: $name"
}

install_adapter deepseek-cc-switch adapters/model-routing/deepseek-cc-switch
install_adapter dual-thread-vision-workflow adapters/visual/dual-thread
install_adapter godot-verification adapters/engine/godot
install_adapter windows-powershell adapters/platform/windows-powershell
install_adapter codex-app-runtime adapters/runtime/codex-app
install_adapter artifact-router adapters/files/artifacts
install_adapter git-worktree-handoff adapters/git/worktree-handoff

AGENTS_PATH="$CODEX_HOME/AGENTS.md"
BOOTSTRAP="$REPO_ROOT/AGENTS.md"
TMP_AGENTS="$AGENTS_PATH.tmp-$STAMP"
if [ -f "$AGENTS_PATH" ]; then
  awk '
    /agent-collaboration-protocol:start/ { skip=1; next }
    /agent-collaboration-protocol:end/ { skip=0; next }
    !skip { print }
  ' "$AGENTS_PATH" > "$TMP_AGENTS"
else
  : > "$TMP_AGENTS"
fi
printf '\n' >> "$TMP_AGENTS"
cat "$BOOTSTRAP" >> "$TMP_AGENTS"
mv "$TMP_AGENTS" "$AGENTS_PATH"

echo "Installed agent-collaboration-protocol into $CODEX_HOME"
echo "Run install/doctor.sh to verify."


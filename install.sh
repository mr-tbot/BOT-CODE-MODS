#!/usr/bin/env bash
# BOT-CODE-MODS installer (macOS / Linux).
# Installs a persistent system prompt into Claude Code and VS Code Chat / Copilot. Optionally installs
# the caveman compression mode.
#
# Examples:
#   bash install.sh
#   bash install.sh --caveman
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CAVEMAN=0; PROMPT_FILE="$ROOT/system-prompt.md"
while [ $# -gt 0 ]; do
  case "$1" in
    --caveman) CAVEMAN=1 ;;
    --prompt) shift; PROMPT_FILE="${1:-}" ;;
    *) echo "unknown option: $1" ;;
  esac
  shift
done

backup_if_exists() { [ -f "$1" ] && cp "$1" "$1.bak-$(date +%Y%m%d-%H%M%S)" && echo "  backed up existing -> $1.bak-*"; return 0; }

[ -f "$PROMPT_FILE" ] || { echo "prompt file not found: $PROMPT_FILE"; exit 1; }
INSTR="$(cat "$PROMPT_FILE")"

# 1. Claude Code
CLAUDE="$HOME/.claude/CLAUDE.md"
mkdir -p "$(dirname "$CLAUDE")"; backup_if_exists "$CLAUDE"
printf '%s\n' "$INSTR" > "$CLAUDE"
echo "[ok] Claude Code  -> $CLAUDE"

# 2. VS Code Chat / Copilot user instructions (all detected variants)
FRONTMATTER=$'---\ndescription: BOT-CODE-MODS global agent instructions (applies to every chat request)\napplyTo: '"'"'**'"'"'\n---\n'
CONTENT="$FRONTMATTER"$'\n'"$INSTR"
case "$(uname -s)" in
  Darwin) BASE="$HOME/Library/Application Support" ;;
  *)      BASE="${XDG_CONFIG_HOME:-$HOME/.config}" ;;
esac
FOUND=()
for v in "Code" "Code - Insiders" "VSCodium"; do [ -d "$BASE/$v/User" ] && FOUND+=("$BASE/$v/User"); done
[ ${#FOUND[@]} -eq 0 ] && FOUND=("$BASE/Code/User")
for u in "${FOUND[@]}"; do
  target="$u/prompts/bot-code-mods.instructions.md"
  mkdir -p "$(dirname "$target")"; backup_if_exists "$target"
  printf '%s\n' "$CONTENT" > "$target"
  echo "[ok] VS Code Chat -> $target"
done

# 3. Optional caveman compression mode (third-party, public)
if [ "$CAVEMAN" = 1 ]; then
  if command -v node >/dev/null 2>&1; then
    echo "[*] Installing caveman (github.com/JuliusBrussee/caveman)..."
    npx -y github:JuliusBrussee/caveman -- --non-interactive || echo "  [warn] caveman auto-detect returned nonzero"
    npx -y github:JuliusBrussee/caveman -- --only claude --with-hooks --force --non-interactive || echo "  [warn] caveman hooks returned nonzero"
    echo "[ok] caveman installed (reload the editor to activate)"
  else
    echo "  [warn] node not found; caveman skipped."
  fi
fi

echo ""
echo "Done. Reload VS Code / restart Claude Code, then in chat ask:"
echo "  'what standing instructions are you following?'"

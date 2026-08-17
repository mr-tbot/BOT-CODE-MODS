#!/usr/bin/env bash
# BOT-CODE-MODS installer (macOS / Linux).
# Installs a persistent system prompt into Claude Code and VS Code Chat / Copilot, plus every agent
# skill under skills/. Optionally installs the caveman compression mode.
#
# Examples:
#   bash install.sh
#   bash install.sh --caveman
#   bash install.sh --no-skills
#   bash install.sh --only-skill auto-audit --only-skill auto-doc
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CAVEMAN=0; SKILLS=1; ONLY_SKILLS=""; PROMPT_FILE="$ROOT/system-prompt.md"
while [ $# -gt 0 ]; do
  case "$1" in
    --caveman) CAVEMAN=1 ;;
    --no-skills) SKILLS=0 ;;
    --no-auto-audit) SKILLS=0 ;;   # deprecated alias, kept so older instructions keep working
    --only-skill) shift; ONLY_SKILLS="$ONLY_SKILLS ${1:-}" ;;
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

# 3. agent skills — every skills/*/SKILL.md (skip with --no-skills, narrow with --only-skill)
if [ "$SKILLS" = 1 ]; then
  SKILL_DIRS=("$HOME/.claude/skills")
  # ~/.agents/skills is the cross-runtime alias (Codex, Copilot CLI, Gemini CLI); mirror only if present
  if [ -d "$HOME/.agents/skills" ]; then SKILL_DIRS+=("$HOME/.agents/skills"); fi
  found=0
  for src in "$ROOT"/skills/*/SKILL.md; do
    [ -f "$src" ] || continue
    name="$(basename "$(dirname "$src")")"
    if [ -n "$ONLY_SKILLS" ]; then
      case " $ONLY_SKILLS " in *" $name "*) ;; *) continue ;; esac
    fi
    found=$((found+1))
    for d in "${SKILL_DIRS[@]}"; do
      target="$d/$name/SKILL.md"
      # A symlinked skill dir/file means the user develops that skill from its own repo.
      # cp would follow the link and overwrite their source, so leave it alone.
      if [ -L "$d/$name" ] || [ -L "$target" ]; then
        echo "[skip] $name — $d/$name is a symlink (live-linked to its source repo)"
        continue
      fi
      mkdir -p "$(dirname "$target")"; backup_if_exists "$target"
      cp "$src" "$target"
      echo "[ok] skill        -> $target"
    done
  done
  if [ "$found" -eq 0 ]; then echo "  [warn] no skills matched; nothing installed from skills/."; fi
fi

# 4. Optional caveman compression mode (third-party, public)
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

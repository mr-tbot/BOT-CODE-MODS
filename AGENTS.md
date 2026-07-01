# AGENTS.md — for any AI agent that opens this folder

This repo (**BOT-CODE-MODS**) is a small kit that installs a **persistent system prompt** into Claude
Code and VS Code Chat / Copilot, plus an **optional accent-colored theme**, so your AI coding tools
follow the same rules on every turn and every project.

If a user asks you to set it up on this machine:
1. Read `README.md` — it's the full guide.
2. Run the installer from this folder:
   - Windows: `powershell -ExecutionPolicy Bypass -File .\install.ps1`
   - macOS / Linux: `bash install.sh`
   Add `-Theme -AccentColor "#RRGGBB"` (PowerShell) or `--theme --accent "#RRGGBB"` (bash) for the
   optional theme; add `-Caveman` / `--caveman` for the optional compression mode.
3. Do not overwrite existing config without backing it up first (the installer already does this).
4. Tell the user to reload VS Code so the changes take effect.

The prompt content is the editable file `system-prompt.md` — edit that to change what the agents are
told; you never edit installer code to change prompt content.

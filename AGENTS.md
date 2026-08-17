# AGENTS.md — for any AI agent that opens this folder

This repo (**BOT-CODE-MODS**) is a small kit that installs a **persistent system prompt** into Claude
Code and VS Code Chat / Copilot, plus the **Auto-\* agent skills**, so your AI coding tools
follow the same rules on every turn and every project.

If a user asks you to set it up on this machine:
1. Read `README.md` — it's the full guide.
2. Run the installer from this folder:
   - Windows: `powershell -ExecutionPolicy Bypass -File .\install.ps1`
   - macOS / Linux: `bash install.sh`
   Add `-Caveman` / `--caveman` for the optional compression mode. Add `-NoSkills` /
   `--no-skills` to skip the agent skills (they install by default), or `-OnlySkill` /
   `--only-skill` to install a subset.
3. Do not overwrite existing config without backing it up first (the installer already does this).
4. Tell the user to reload VS Code so the changes take effect. Skills load when a session starts, so
   Claude Code needs a restart before `/auto-audit` and the other skills are available.

The prompt content is the editable file `system-prompt.md` — edit that to change what the agents are
told; you never edit installer code to change prompt content. Likewise, skill content lives in
`skills/<name>/SKILL.md`; the installer copies every directory it finds there, so adding a skill
means adding a folder, not editing installer code.

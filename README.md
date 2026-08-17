# BOT-CODE-MODS

**Give your AI coding tools one consistent brain.** BOT-CODE-MODS installs a persistent *system
prompt* into both **Claude Code** and **VS Code Chat / GitHub Copilot** so every chat turn, in every
project, follows the same rules you set. It also installs the **auto-audit** agent skill, and ships an
**optional token-compression mode**.

It's a handful of small scripts and editable Markdown — no framework, no telemetry, no account.

---

## Why

AI assistants forget your preferences between chats and behave differently across tools. Claude Code
reads a `CLAUDE.md`; VS Code Chat / Copilot read *instruction files*. BOT-CODE-MODS writes the **same
prompt** into both, globally, so you get consistent behavior (your rules, your tone, your guardrails)
without repeating yourself.

- **One prompt, both tools, every turn** — Claude Code loads it each session; Copilot/Chat attaches it
  to every request via `applyTo: '**'`.
- **Editable, not hard-coded** — the prompt lives in `system-prompt.md`. Edit it, re-run the installer,
  done. You never touch installer code to change what the agents are told.
- **Cross-platform** — Windows (PowerShell) and macOS/Linux (bash).

---

## Requirements

- **VS Code** with **Claude Code** and/or **GitHub Copilot Chat** (whichever you use).
- **Node.js ≥ 18** — only needed for the optional caveman mode. The core prompt install works
  without it.
- **git** — only if you want to `git clone` the repo (you can also download the ZIP).

The core prompt install has **no dependencies** beyond your shell.

---

## Install

```bash
git clone https://github.com/<your-account>/BOT-CODE-MODS.git
cd BOT-CODE-MODS
```

**Windows (PowerShell):**

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

**macOS / Linux (bash):**

```bash
bash install.sh
```

Then **reload VS Code** (`Developer: Reload Window`) and/or restart Claude Code. To confirm it's
active, open chat and ask: *"what standing instructions are you following?"*

### Options

| Goal | PowerShell | bash |
|------|------------|------|
| Prompt + auto-audit skill (default) | `install.ps1` | `install.sh` |
| Skip the auto-audit skill | add `-NoAutoAudit` | add `--no-auto-audit` |
| Also install caveman compression | add `-Caveman` | add `--caveman` |
| Use a different prompt file | `-PromptFile .\my-prompt.md` | `--prompt ./my-prompt.md` |

---

## What it does, exactly

| Target | Path | Notes |
|--------|------|-------|
| Claude Code | `~/.claude/CLAUDE.md` | loaded at the start of every Claude Code session |
| VS Code Chat / Copilot | `<VS Code User>/prompts/bot-code-mods.instructions.md` | `applyTo: '**'` attaches it to every chat request |
| auto-audit skill | `~/.claude/skills/auto-audit/SKILL.md` | also mirrored to `~/.agents/skills/` if that directory already exists |

`<VS Code User>` is `%APPDATA%\Code\User` (Windows), `~/Library/Application Support/Code/User`
(macOS), or `~/.config/Code/User` (Linux). VS Code **Insiders** and **VSCodium** are detected and
handled too. Any file it would overwrite is backed up to `*.bak-<timestamp>` first.

> The Copilot/Chat instruction file lives in VS Code's *prompts* area, which **VS Code Settings Sync**
> can sync across your machines. `~/.claude/CLAUDE.md` is outside VS Code and does not sync — install
> it per machine (or keep it in your own dotfiles).

---

## Customize the prompt

Open **`system-prompt.md`** and make it yours — your voice, your rules, your do's and don'ts. Then
re-run the installer to push the change to Claude Code and Copilot/Chat everywhere. That's the whole
workflow; the prompt is data, not code.

A second file, **`bootstrap-prompt.md`**, is a paste-in prompt that sets up a lightweight per-project
"agent system" (a `.agent/MEMORY.md`, an `AGENTS.md`, standing rules) in any new or existing repo.
It's optional and self-contained — paste it into your AI chat from inside a project.

---

## The auto-audit skill

`skills/auto-audit/SKILL.md` is an agent skill that refuses to let a project be called finished before
it actually is. It drives an iterative **audit → fix → build → verify → adversarially review → audit
again** loop across every platform the project ships to — the machine the agent is running on
included — and keeps looping until a complete pass turns up nothing.

It exists because agents are good at producing code that compiles, launches, renders a UI, and moves
zero bytes: a callback wired nowhere, an interface method that silently returns nothing, a counter
incremented on the wrong side of the failure. The skill defines "finished" as *the runtime path
demonstrably works on each target, with the log line to prove it* — not "it builds".

Invoke it in chat with `/auto-audit`, or let it trigger itself when the agent is about to declare a
feature done, a capability impossible, a platform unsupported, or a build ready to ship. Shipping
stays your call: after a clean pass it reports ready and lists the project media the work invalidated,
but never pushes or submits on its own.

Skip it with `-NoAutoAudit` / `--no-auto-audit`. Upstream lives at
[mr-tbot/Auto-Audit](https://github.com/mr-tbot/Auto-Audit); the copy here is vendored so this kit
installs standalone.

---

## Caveman mode (optional)

`-Caveman` / `--caveman` installs [caveman](https://github.com/JuliusBrussee/caveman), a third-party,
open-source "compressed communication" mode that reduces token usage. It's independent of this kit and
entirely optional; omit the flag if you don't want it.

---

## Uninstall

- **Prompt:** delete `~/.claude/CLAUDE.md` and `<VS Code User>/prompts/bot-code-mods.instructions.md`
  (or restore their `*.bak-*` backups).
- **auto-audit:** delete `~/.claude/skills/auto-audit/` (and `~/.agents/skills/auto-audit/` if present).
- **Caveman:** `npx -y github:JuliusBrussee/caveman -- --uninstall`.

---

## Files

- `system-prompt.md` — the system prompt (edit this).
- `bootstrap-prompt.md` — optional paste-in prompt to scaffold a project's agent system.
- `skills/auto-audit/SKILL.md` — the auto-audit agent skill.
- `install.ps1` / `install.sh` — the installers.
- `AGENTS.md` — a pointer so an AI agent opening this folder knows how to install it.
- `LICENSE` — MIT.

---

## FAQ

**Does the prompt really apply on every turn?** For Claude Code, `CLAUDE.md` is loaded per session and
stays in context. For VS Code Chat / Copilot, the instruction file uses `applyTo: '**'`, which attaches
it to every request. Verify by asking chat what instructions it's following.

**I don't use Copilot / I only use Copilot.** That's fine — the installer writes both targets; the one
you don't use is simply inert.

**Is anything sent anywhere?** No. The scripts only write local files. The optional caveman flag
fetches that separate open-source project from GitHub; nothing else leaves your machine.

**Windows script won't run.** Use `-ExecutionPolicy Bypass` as shown, or unblock the file. The scripts
are plain text — read them first if you like.

---

## License

MIT — see [LICENSE](LICENSE). Contributions welcome.

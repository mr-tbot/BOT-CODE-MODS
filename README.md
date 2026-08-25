# BOT-CODE-MODS

**Give your AI coding tools one consistent brain.** BOT-CODE-MODS installs a persistent *system
prompt* into both **Claude Code** and **VS Code Chat / GitHub Copilot** so every chat turn, in every
project, follows the same rules you set. It also installs the **Auto-\* agent skills** — a family of
finish-the-job audits — and ships an **optional token-compression mode**.

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
| Prompt + all skills (default) | `install.ps1` | `install.sh` |
| Skip the skills | add `-NoSkills` | add `--no-skills` |
| Install only certain skills | `-OnlySkill auto-audit,auto-doc` | `--only-skill auto-audit --only-skill auto-doc` |
| Also install caveman compression | add `-Caveman` | add `--caveman` |
| Use a different prompt file | `-PromptFile .\my-prompt.md` | `--prompt ./my-prompt.md` |

---

## What it does, exactly

| Target | Path | Notes |
|--------|------|-------|
| Claude Code | `~/.claude/CLAUDE.md` | loaded at the start of every Claude Code session |
| VS Code Chat / Copilot | `<VS Code User>/prompts/bot-code-mods.instructions.md` | `applyTo: '**'` attaches it to every chat request |
| Agent skills | `~/.claude/skills/<skill>/SKILL.md`, one per directory under `skills/` | also mirrored to `~/.agents/skills/` if that directory already exists |

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

## The Auto-* skills

Everything under `skills/` is installed as an agent skill you can invoke by name (`/auto-audit`) or
let trigger itself when it applies. They share one idea: an agent should not be allowed to call
something finished before it demonstrably is.

| Skill | Refuses to let you ship |
|---|---|
| **auto-audit** | A feature that compiles but moves zero bytes. Iterative audit → fix → build → verify → adversarially review, across every platform the project targets — the machine the agent runs on included — until a pass finds nothing |
| **auto-rewrite** | Code that came from somewhere else. Duplication sweep, provenance search against the archives that actually hold the world's source, git forensics — then a remediation ladder where rewriting is the fifth option |
| **auto-license-check** | A dependency whose license nobody read. Asks how you actually release before it scans, opens the shipped artifact rather than trusting metadata, and treats an unknown license as a blocker |
| **auto-ui-ux** | An interface built in phases that never got unified — and controls that render beautifully while doing nothing. Drift, WCAG 2.2 AA in every theme, the state matrix, and a wiring pass that traces every control to a real effect |
| **auto-doc** | Documentation, changelogs, wikis and feature claims the code has outrun — including in-product copy and the locales still promising a removed feature |
| **auto-skill-update** | Skills and plugins quietly running a version behind the repo they came from. Most are bare directories with no version and no remote, so it establishes provenance first — manifests, on-disk source repos, then content fingerprint search for the ones that aren't obvious — and never calls a skill it could not identify up to date |

Also vendored here, same as upstream: auto-web, auto-brand-parity, auto-media-maker,
auto-balance, auto-issue-fix, auto-audit-security, auto-comment, and auto-everything
(the whole family as one pass, in dependency order).

Each skill defines "finished" as *demonstrably works, with the evidence to prove it*, and none of them
ship, push, submit or post on your behalf — that stays your call.

Skip them with `-NoSkills` / `--no-skills`, or install a subset with `-OnlySkill` / `--only-skill`.
Upstream is [mr-tbot/Auto-Everything](https://github.com/mr-tbot/Auto-Everything); the copies here are
vendored so this kit installs standalone.

---

## Caveman mode (optional)

`-Caveman` / `--caveman` installs [caveman](https://github.com/JuliusBrussee/caveman), a third-party,
open-source "compressed communication" mode that reduces token usage. It's independent of this kit and
entirely optional; omit the flag if you don't want it.

---

## Uninstall

- **Prompt:** delete `~/.claude/CLAUDE.md` and `<VS Code User>/prompts/bot-code-mods.instructions.md`
  (or restore their `*.bak-*` backups).
- **Skills:** delete the `auto-*` directories from `~/.claude/skills/` (and `~/.agents/skills/` if present).
- **Caveman:** `npx -y github:JuliusBrussee/caveman -- --uninstall`.

---

## Files

- `system-prompt.md` — the system prompt (edit this).
- `bootstrap-prompt.md` — optional paste-in prompt to scaffold a project's agent system.
- `skills/<name>/SKILL.md` — the agent skills; every directory here gets installed.
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

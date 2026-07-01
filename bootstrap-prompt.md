# Project Bootstrap Prompt

Use this to set up a lightweight "agent system" in a project so any AI assistant behaves consistently
in it. Works on a brand-new empty folder OR an existing codebase. Paste it into your AI chat (Claude
Code, Copilot, etc.) from inside the project folder and send.

## Phase 0 — Detect what you're working with
Inspect the folder. Determine:
- Is there existing code? (manifests like `package.json` / `pyproject.toml` / `Cargo.toml` / `go.mod`
  / `*.csproj`, a `src/` tree, etc.)
- Is there existing git history?
- Do standard files already exist? (`README.md`, `AGENTS.md`, `CLAUDE.md`,
  `.github/copilot-instructions.md`, `CONTRIBUTING.md`, CI configs, a `.agent/` folder)

State which path you're taking in one line:
- Empty / near-empty folder -> **PATH A (new project)**
- Existing codebase -> **PATH B (adopt existing)**

Never overwrite standard files blindly — read and merge; back up anything you rewrite to
`.agent/backups/`.

## PATH A — New project
Ask only what you need, in small batches: what it is and who it's for; platforms/targets; constraints
(performance, offline, budget, timeline, systems it must talk to); success criteria and MVP vs later.
Then present **2-4 viable directions** (languages / frameworks / architecture) with honest pros and
cons and a recommendation, and let the user choose. Check current docs for versions and best
practices. Once aligned, go to Phase 3.

## PATH B — Adopt existing project
Read enough of the repo to understand it before asking anything. Note: stack and architecture, entry
points, build/test/run/deploy commands, what it does, where config lives, and the dominant UI/style
conventions if there's a UI. Read any existing `README`/`AGENTS`/`CONTRIBUTING` and plan to augment,
not replace. Show a short summary of what you inferred, then ask ONLY what the code can't tell you.
Then go to Phase 3.

## Phase 3 — Scaffold the agent system (both paths)
Create (or merge into) these:
- `.agent/` and `.agent/backups/` (add `.agent/` to `.gitignore`).
- `.agent/MEMORY.md` — project identity, stack, decisions + rationale, current state / next steps, and
  a cold-start resume point. Keep it updated every session.
- `AGENTS.md` — agent-facing guide: structure, conventions, build/test/run commands, and the canonical
  UI/style conventions. Embed the standing rules below.
- `README.md` — public-grade: what it is, setup/config, run/build/deploy commands, usage, an
  architecture overview, and troubleshooting. Improve an existing README rather than replacing it.
- `.gitignore` — ensure `.agent/`, `.env`, and common secret files are ignored.

Then give a short summary and a recommended next step. On an existing project, list findings but don't
start changing code until told to.

## Standing rules (embed these in AGENTS.md)
- Maintain `.agent/MEMORY.md`; read it first each session.
- Back up a file before a significant edit; note how to revert just that change.
- Confirm destructive/irreversible actions; never bypass safety checks.
- Install needed SDKs/dependencies yourself; only stop for genuine blockers (paid assets, secrets,
  consent, real ambiguity).
- Verify changes by running them and reading real output before claiming success.
- Warn before expensive actions and prefer the cheaper path.
- Keep secrets out of code, logs, and commits.
- When extending a UI, match existing conventions; clear major style changes first.
- Keep `README.md` and `AGENTS.md` current.

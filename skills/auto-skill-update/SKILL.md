---
name: auto-skill-update
description: "Use when the agent skills, plugins and marketplaces installed on this machine may have fallen behind the repositories they came from — when the user asks whether their skills are current, wants them updated, mentions a skill behaving like an older version, has just set up a new machine, or says \"/auto-skill-update\"; or before relying on a skill whose upstream has moved."
---

# /auto-skill-update

Find every skill and plugin installed on this machine, work out where each one actually came from,
and compare it against what that source ships today.

**The problem is identification, not comparison.** A skill on disk is usually a bare directory with
a `SKILL.md` in it: no version, no commit, no remote, nothing that says where it came from. Most
installers copy files rather than cloning, so the absence of a `.git` proves nothing at all. Until
you know a skill's origin you cannot answer "is it current?", and the honest answer is not "yes".

So this runs in two halves: establish provenance, then check freshness. The first half is the work.

## Step 0 — Enumerate Every Install Surface

Miss a surface and the audit reports clean on skills nobody looked at.

- **User skills** — `~/.claude/skills/*/SKILL.md`
- **Project skills** — `.claude/skills/` in the repo, and in any other repo the user works in
- **Plugins** — `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/`
- **Plugin manifests** — `~/.claude/plugins/installed_plugins.json` and `known_marketplaces.json`
- **Vendor copies in source repos** — a skill can live in a repo *and* be installed from it, and the
  two drift independently
- Whatever else the platform supports: check the docs rather than assuming this list is complete

**The same skill can exist on more than one surface, with different contents.** Record every copy
separately. Which one the agent actually loads is a precedence question, and precedence has nothing
to do with which is newest — a stale project copy silently shadowing a fresh user copy is a real and
confusing failure.

## Step 1 — Provenance: Work Out What You Actually Have

Run the ladder in order and stop at the first rung that *proves* origin. Cheap and certain first.

**1. Plugin manifests — authoritative, so start here.**
`installed_plugins.json` carries the version, the `gitCommitSha` and the install path;
`known_marketplaces.json` maps the marketplace to its GitHub repo. For anything installed as a
plugin, provenance is already recorded and this step is free.

**2. Source repos on this machine.** If a checkout on disk contains a byte-identical copy of the
installed skill, that is proof of origin, and its `git remote` gives you the upstream for free.
This is the single highest-yield rung for anyone who installs their own skills from their own repos,
because installers copy: the installed file and the repo file match exactly.
```bash
cmp -s ~/.claude/skills/<name>/SKILL.md <repo>/skills/<name>/SKILL.md && echo "origin proven"
```

**3. A known-upstream table** for the widely-distributed collections — the vendor's own skills
repository, the marketplaces already registered on this machine, any collection the user has
mentioned. Match on directory name *and* confirm by content; name alone is a guess, because two
collections can ship a skill with the same name.

**4. Content fingerprint search.** For anything still unidentified, take a distinctive sentence from
the middle of `SKILL.md` — not the title, not the frontmatter, something long and unusual enough to
be unique — and search code hosts for it. GitHub's code search API is the obvious tool, and note it
requires authentication and rate-limits hard, so search the *unknowns* rather than everything, and
cache what you find. A verbatim hit in a repository is strong evidence; confirm it by diffing the
whole file before you believe it.

**5. Internal clues.** Frontmatter fields, an author line, a URL in the prose, a companion README,
an entry in the user's own notes or ecosystem digest. Weak on their own, useful for choosing which
candidate to verify.

**6. Ask.** If the ladder runs out, ask the user where a skill came from. One answer, recorded, is
cheaper than re-deriving it on every run forever.

**An unidentified skill is reported as UNKNOWN, never as up to date.** This mirrors the rule in
`auto-license-check`: you do not get to downgrade "I could not determine this" into "it is probably
fine". UNKNOWN is the finding, and it is the one worth fixing first, because every future run stays
blind until it is resolved.

## Step 2 — Resolve What Upstream Ships Today

How you ask depends on the source, and the cheap question is usually enough:

- **Plugin from a marketplace** — compare the recorded `gitCommitSha` against the marketplace repo's
  current head for that plugin's path.
- **A repo you can reach** — `git ls-remote` answers "what is the head?" without cloning anything.
- **A single file on a host** — a conditional request (`If-None-Match` / `If-Modified-Since`) answers
  "has this changed?" for almost no quota. Prefer it over downloading and diffing.
- **A repo with releases or tags** — a tag is a better answer than a branch head when the project
  actually tags, because a branch head moves on every typo fix.

Be careful reading version numbers: a `version` field inside a plugin manifest is whatever the author
wrote, and can lag the code it describes. A commit or a content hash is a fact; a version string is a
claim.

## Step 3 — Compare, With Three Outcomes And Not Two

- **CURRENT** — installed content matches upstream.
- **BEHIND** — upstream has changed and the local copy is unmodified. Safe to update.
- **DIVERGED** — the local copy differs from *both* the last-known upstream and the current one. The
  user edited it.

**DIVERGED is the outcome that matters, and the one a naive updater destroys.** People tune skills in
place — that is a reasonable thing to do with a plain text file that steers an agent, and this user
base does it constantly. An update that overwrites a locally-edited skill silently deletes work
nobody backed up. Detect divergence before offering to update anything, and never resolve it by
clobbering: show the diff, and let the user choose between keeping their edits, taking upstream, or
merging. If a local edit is worth keeping, the right home for it is the upstream repo, so say so.

## Step 4 — Report Before Touching Anything

One row per installed copy: name, surface, resolved origin (or UNKNOWN), how origin was established,
installed version/commit/hash, upstream version/commit/hash, verdict, and what updating would change.

Group by verdict and lead with UNKNOWN and DIVERGED, because those need a decision. BEHIND is a
routine list. CURRENT is a count, not a table — nobody reads forty rows of "fine".

State the coverage honestly: which surfaces were scanned, how many skills were identified and by
which rung, how many remain UNKNOWN, and what was not checked because a host was unreachable or a
rate limit was hit. A run that could not reach a host is not a run that found everything current.

## Step 5 — Update, On Approval, Reversibly

Updating is a change to the user's environment, so it is a separate, approved step, and each update
is per-skill rather than one blanket yes.

- **Back up what you replace.** A copy of the previous `SKILL.md` costs nothing and is the only thing
  standing between a bad upstream change and a lost afternoon.
- **Prefer the installer the skill came with.** If a collection ships an `install.sh` or a plugin
  command, use it — it knows about surfaces you may not, and hand-copying files behind an installer's
  back produces a state it cannot reason about later.
- **Update every copy, or say which you did not.** If a skill exists on two surfaces and you refresh
  one, the other now shadows or is shadowed by a different version, which is worse than before.
- **Never update a DIVERGED skill without an explicit instruction about the local edits.**

## Step 6 — Record Provenance So The Next Run Is Cheap

Write what you learned to a cache outside the skill directories — a skill directory should stay
exactly what upstream ships, so a content comparison keeps working. Record per skill: the resolved
origin, how it was proven, the upstream ref, the content hash at last check, and the timestamp.

That file turns the expensive half of this skill into a lookup, and it is what makes a routine
"anything stale?" check cheap enough to run often.

## Throttle It

Freshness checks are network calls against rate-limited APIs, and skills do not move hourly. Keep a
last-checked timestamp and default to something like weekly, with an explicit run always allowed to
bypass it. Do not check on every session start; that is how a token budget and an API quota get
spent on an answer that was "no change" forty times in a row.

Notify rather than auto-apply. Tell the user what moved and let them say go — the same pattern their
existing update checks already use.

## Rationalization Table

| Excuse | Reality |
|---|---|
| "No `.git`, so it did not come from a repo" | Installers copy. Absence of `.git` is the normal case, not evidence |
| "Same name, so it is the same skill" | Two collections can ship the same name. Confirm by content |
| "It has no version, so I cannot check it" | Content hash against upstream answers it without any version at all |
| "I could not identify it, so it is probably fine" | UNKNOWN is the finding. Do not launder it into CURRENT |
| "The manifest says 1.4.2, so it is 1.4.2" | A version string is a claim. A commit or hash is a fact |
| "Upstream changed, so update it" | Not if the user edited it locally. Check for divergence first |
| "I will just overwrite and re-apply their edits after" | You will not, and nobody backed them up. Show the diff, ask |
| "I updated the user copy" | And the project copy now shadows it. Update every copy or report which you skipped |
| "I will check on every session start" | Weekly, throttled, cached. Skills do not move hourly |
| "The API rate-limited me, so this run found nothing stale" | It found nothing. Say so — that is not the same as everything being current |

## Red Flags — Keep Working

- Reporting "all skills current" when some were never identified
- Concluding origin from a directory name without a content check
- A freshness verdict for a skill whose upstream you never actually reached
- Overwriting a locally-modified skill, or noticing the modification only afterwards
- Updating one surface and leaving another copy shadowing it
- Writing provenance state *into* the skill directory, which breaks the next content comparison
- Running unthrottled checks against a rate-limited API on every session
- Applying updates without per-skill approval, or without a backup of what was replaced

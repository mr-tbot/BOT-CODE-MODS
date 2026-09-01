---
name: auto-everything
description: "Use when a project should be taken from wherever it is to genuinely shippable in one pass — issues triaged and fixed, code audited, UI and docs and media and infrastructure caught up; when the user says do everything, full pass, get this release-ready, run all the audits, or \"/auto-everything\"; or when several of the Auto-* skills would each apply and running them in the right order matters."
---

# /auto-everything

Run the whole family in dependency order, carrying findings forward, until the project is genuinely
shippable — and stop at the line where shipping is your decision.

**Why order matters.** These skills feed each other. Fixing a wiring break changes what the UI audit
sees. Replacing a dependency changes the license report. Any code change invalidates documentation and
video. Running them in the wrong order means doing the same work twice and reporting stale findings.

## Step 0 — Balance First, Always

Start with **`/auto-balance`**. It sizes this session's parallelism and decides whether the machine
can take the work at all. Everything after it is expensive; finding out mid-build that three other
sessions are compiling is the wrong time.

If balance says the machine is saturated, the correct move is to wait or reduce scope — say so rather
than pressing on. Every build, render and test in this pass then goes through `aw run` (see
`/auto-balance` Step 3): a full pass is exactly the situation where several windows start heavy work
at once, and on a shared-cgroup machine an overrun takes every session down, not just this one.

Then run **`/auto-device-lock`** and claim whatever hardware this pass will touch — phones, boards,
test devices — for the whole pass, up front. A full pass runs builds, screenshots, recordings and
video capture against the same device over hours, and discovering at Step 5 that another window took
the phone means re-shooting everything already captured. Claim once, verify before each batch, release
at the end.

Balance decides **how many** agents. It does not decide **which tier** they run at, and on a long pass
that choice moves the bill more than anything else. If the user has named a policy, follow it:
**`/auto-agent-eco`** keeps subagents strictly below the orchestrator's tier, so the expensive model
routes and merges while cheaper ones do the legwork; **`/auto-agent-max`** lifts that ceiling for work
where a peer-tier subagent genuinely earns its cost. Either accepts a number as a hard cap on how many
subagents may run — `/auto-agent-eco 6`.

Neither policy can raise balance's number. A cheaper agent still occupies a slot on the machine and
still counts against account limits, and a peer-tier one is heavier per agent rather than lighter —
so max mode reaches the ceiling sooner, not later. **Resource limits win over cost policy in both
directions.** With no policy named, route by task, keep the synthesis with the orchestrator, and say
in the final report which tiers ran where.

## Step 1 — Intake: What Are We Actually Fixing?

Run **`/auto-issue-fix`** in **read-only intake mode** first. Pull the reported problems from every
tracker and crash reporter, classify them, and merge them into one work list. Do not write anything
back yet — replies come after fixes are real.

This front-loads reality: the backlog decides the pass's scope, and a crash affecting users outranks
anything you would have found by browsing.

Then agree the scope with the user: everything, or this release only.

## Step 2 — Provenance And Licensing, Before You Write Code

Run **`/auto-rewrite`** and **`/auto-license-check`** now, not later, because both can force
*architectural* changes. Discovering after a week of polish that a core dependency is AGPL, or that a
load-bearing file was copied from an incompatible project, invalidates everything built on top.

These two run cleanly in parallel — they share no state and touch nothing.

Their blockers become work items ahead of everything else.

## Step 3 — Make It Actually Work

Run **`/auto-audit`**. This is the spine of the pass: every claimed feature traced to a real runtime
path, on every platform the project targets, iterating until a pass finds nothing.

**Its adversarial stage is several passes, not one** — red (break it), blue (would anything notice),
yellow (is it built the way this project builds things), then the derived passes: purple (a regression
test and a detection for every red finding), orange (the change that removes the whole class), green
(is it deployed and integrated correctly), white (rules of engagement and who says done), black (the
surface outside the repository). One reviewer wearing one hat finds one class of defect. Run red
first; purple and orange consume its output and produce nothing without it.

Fix the intake list from Step 1 here too — with a regression test per fix, per auto-issue-fix's
discipline. A fix without a failing-then-passing test is a guess.

**Do not proceed while auto-audit is still finding defects.** Everything downstream describes,
photographs or deploys this code; documenting a broken build produces accurate documentation of a
broken build.

## Step 4 — Interface

Run **`/auto-ui-ux`**. Its wiring pass will surface dead controls — and **a wiring break sends you back
to Step 3**, because a disconnected control means a wiring pass was skipped somewhere. That loop is
part of the design, not a detour.

Run **`/auto-brand-parity`** alongside it. They overlap at the edges (icons, palette, contrast of brand
colors used as accents) and are best reconciled together rather than fighting each other later.

## Step 5 — Tell The Truth About It

Only now, with the code settled, do the descriptive passes — anything earlier documents a moving
target.

- **`/auto-doc`** — README, changelog, docs site, wikis, feature claims, in-product copy, store
  listings.
- **`/auto-media-maker`** — its `check` names exactly which videos and which beats the code outran.
- **`/auto-media-onboarding`** — the first-run film, if the flow it teaches moved. It is the video
  that generates support tickets when it is stale, so it outranks the rest of the series.
- **`/auto-media-stinger`** — the launch commercial, last, and only if the claims it makes are no
  longer true. It changes least and costs most to redo.

Every screenshot and capture in this step needs a device lease held and verified — see Step 0.

These parallelize well. Both are cheap to re-run if Step 3 reopens.

## Step 6 — Infrastructure

Run **`/auto-web`** — read-only first, always. It reports whether what is deployed matches what you
now have, and what would have to change.

It sits here because deploying is downstream of everything: there is no point reconciling
infrastructure against code that is about to change again.

## Step 7 — Close The Loop

Return to **`/auto-issue-fix`**, now in **write mode**, under its gates:

- Reply to each report with the actual fix and the commit or PR that carries it.
- Close what is genuinely fixed, with the honest `state_reason`.
- File new issues for what this pass found and did not fix.
- Update the trackers.

Per-item approval still applies. A batch pass is exactly the situation that produces mass-comment spam,
so the gates matter more here, not less.

## Step 8 — The Handoff

Produce one consolidated report, `.audit/everything-report.md`:

- What each skill found and what was fixed
- What remains, ranked, with an estimate
- Every deliberate compromise, and why
- What could not be verified, and what it would take
- **The ship checklist**: what is ready, and what is explicitly waiting on your decision

**Then stop.** Nothing in this family pushes, tags, submits to a store, deploys, or posts publicly on
its own. The pass ends with a recommendation and a clean tree, and shipping is a separate, explicit
instruction.

## Iterate

One pass is never enough — every pass so far has found real defects the previous one missed, including
in code written earlier in the same session.

Re-enter at the earliest step whose inputs changed:

| What changed | Re-enter at |
|---|---|
| Code fixed | Step 3, then everything downstream |
| A wiring break found | Step 3 |
| A dependency swapped | Step 2 |
| UI changed | Step 4, then docs and media |
| Only prose changed | Step 5 |

Stop when a complete cycle finds nothing new. Report the cycle count.

## Running It Sanely

**Checkpoint between steps.** Commit at each boundary so a step can be reverted alone. A single
enormous diff across eleven concerns is unreviewable, and unreviewable work does not get reviewed.

**Report progress as you go**, not only at the end. A pass this long that goes silent is
indistinguishable from a pass that hung.

**Budget honestly.** Before starting, estimate roughly what the full pass costs in time and credits and
offer a scoped-down version — release-critical only, or a single platform. `/auto-media-maker`,
`/auto-media-stinger` and `/auto-audit` are the expensive ones.

**Respect every sub-skill's gates.** Running under one command does not upgrade anyone's permissions.
Anything the individual skill would have asked about, this one asks about too — store-review replies,
production changes, license changes, publishing. The orchestration is a convenience, never a
consent-laundering mechanism.

## Rationalization Table

| Excuse | Reality |
|---|---|
| "I'll do docs first, they're easy" | You will document code that is about to change |
| "Licensing can wait until the end" | An AGPL dependency is architectural. Find it before you build on it |
| "auto-audit still has findings, but let's proceed" | Everything downstream describes this code. Fix it first |
| "One big commit at the end is cleaner" | It is unreviewable, and it cannot be partially reverted |
| "The user said do everything, so I can ship" | Everything ends at ready. Shipping is a separate instruction |
| "Running under one command, so I don't need to ask" | Gates are per action, not per invocation |
| "One pass is enough this time" | It never has been. Run the cycle until it comes back empty |
| "I reviewed it adversarially" | From which seat? Red, blue and yellow find different defects, and purple and orange only exist once red has run |
| "The machine is busy but I'll start anyway" | Balance runs first for a reason |
| "I'll claim the phone when I get to the media step" | Another window will have it by then, and the shots already taken will not match |
| "I'll batch all the issue replies at the end" | That is the mass-comment pattern. Per-item approval still applies |

## Red Flags — Stop

- Starting without `/auto-balance`
- Capturing a screenshot, a recording or a device test without a verified lease from
  `/auto-device-lock` — a pass that loses the device halfway reshoots everything
- Documenting or filming code that `/auto-audit` still has open findings against
- Running licensing or provenance after the implementation work
- Writing to trackers before the fixes are real and verified
- One giant uncommitted diff spanning every concern
- Treating the orchestration as blanket approval for a sub-skill's gated action
- Declaring the pass complete after one cycle
- Collapsing the team passes into a single "adversarial review" and reporting it as all of them
- Shipping anything — that is never this skill's call

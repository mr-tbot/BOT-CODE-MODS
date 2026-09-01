---
name: auto-audit
description: "Use when a project must be driven to genuine completion on every platform it targets — user says \"finish this\", \"don't stop until it's done\", \"100% complete\", \"keep doing passes\", \"audit this until it's done\", \"/auto-audit\"; when they ask for a red-team, blue-team or multi-team pass over a project's correctness; or when about to declare a feature done, a capability impossible, a platform unsupported, or a build ready to ship."
---

# /auto-audit

Iterative audit → fix → build → verify → adversarially review → audit again, until a full pass turns up
nothing. "Doesn't exist yet" is a research task, not a stopping point.

## Step 0 — Enumerate The Targets

Before the first pass, write down every platform this project targets, and keep the list visible.
It is the checklist every later stage runs against. Sources: build config, CI matrix, packaging
scripts, README install section, the user.

Targets are whatever the project actually ships to — mobile OSes, desktop OSes, browsers (and the
ones you don't develop in), server runtimes and their versions, CPU architectures, containers,
embedded boards, CLI shells, plugin hosts, store/distribution channels.

**Include the platform you are running on right now.** It is a target too, not the neutral place
you build from. The host is where verification is cheapest and therefore the one most often
declared done on inspection alone — verify it like any other.

If the project targets exactly one platform, say so explicitly and move on. If you can't determine
the list, ask — guessing the target set undermines every pass that follows.

## The Loop

Run every stage against every target from Step 0. Never skip to the end because the last pass
looked clean.

1. **Audit** — walk every feature the project claims. For each, name the exact runtime path that
   makes it work, file:line, on each target. A feature with no traceable runtime path is not
   implemented. Platform-conditional code (`#ifdef`, `Platform.OS`, `os.name`, feature detection,
   per-target build flavors) gets audited per branch — one branch working says nothing about its
   sibling.
2. **Fix** — implement what the audit found. Be thorough and precise; no stubs, no TODO-and-move-on.
3. **Build** — every target, every time. A green build on one target proves nothing about the rest.
4. **Verify in the real environment** — run the actual thing on each target and read the actual
   logs. See below.
5. **Adversarially review, by team** — hunt for what the fix pass missed, assuming it missed
   something. One reviewer wearing one hat finds one class of defect; the team colours below are how
   you get the other classes.
6. **Go to 1.** Stop only when a complete pass finds nothing new on any target.

**Targets you genuinely cannot reach** (no hardware, no license, no runner) get named explicitly,
with what's missing and what it would take. Try the cheap substitutes first — VM, container, CI
runner, cross-compile plus a smoke run, a borrowed device. An unreachable target is reported as
unverified, never counted as done.

**Respect the project's device policy.** Where real hardware is attached, it is the target — an
emulator or simulator is a fallback, not an equivalent, and some projects forbid them outright
(they are heavy enough to destabilise a shared build machine, and they do not reproduce real
hardware behaviour). Check the policy before starting one; absent a policy, prefer hardware and
label any emulator result as such. Never silently substitute an emulator for the device.

**One pass is never enough.** Every pass finds real defects the previous one missed — including in
code written earlier in the same session. A pass that finds nothing on its first run means the audit
was too shallow, not that the project is done.

### After a clean pass

- Note every change needed in project media (video, screenshots, store listings, README assets, demo
  captures) that the new work invalidates. Stale media is an unfinished feature.
- **Push / release / submit to any platform only on explicit user approval.** Report ready; do not ship.

## The Team Passes

Stage 5 is not one review, it is several, each run from a different seat. The colours come from the
InfoSec colour wheel (April C. Wright, 2017): **red, blue and yellow are the primaries; purple,
orange and green are what you get by combining them.** White is the referee — NIST defines a White
Team as the group refereeing an engagement between a Red Team of mock attackers and a Blue Team of
defenders. Black is **not** a standard term; it is used here for the surface that is not the code.

The point is not ceremony. It is that each seat is blind to what the others see, and a project
audited from one seat is a project whose other failure classes were never looked for.

| Pass | The seat | What it asks of a feature that "works" |
|---|---|---|
| **Red** | breaker | What input, ordering or environment makes this fail? The unhappy path, the empty state, the second concurrent caller, the platform you did not develop on, the input a hostile user sends |
| **Blue** | defender | When it does fail, does anything notice? Is there a log, an error surface, a metric, a recovery? Does it fail *safe*, or fail silently with a plausible-looking wrong answer? |
| **Yellow** | builder | Is it built the way this project builds things — the existing helper, the existing pattern, the existing error type? Would the next maintainer find it where they expect? |
| **Purple** | red + blue | For every break Red found: is there now a **regression test** that fails without the fix, and a way to *detect* it in the wild if it recurs? A fix with no detection is a fix you will make again |
| **Orange** | yellow + red | For every break Red found: what would have to change about **how it is built** so the whole class cannot recur? One guard in the shared function beats a guard in every caller |
| **Green** | yellow + blue | Is it deployed and integrated correctly on each target — packaging, permissions, config, migrations, first-run state? Code that is correct and shipped wrong is not finished |
| **White** | referee | What are the rules of engagement, what counts as evidence, and who says "done"? Records what was out of scope and why, adjudicates disputes between passes, and holds the line that shipping is the user's call |
| **Black** | outside the code | The surface the repository does not contain: physical devices and their state, the supply chain, out-of-band paths (a cron job, a webhook, a support tool), and the human step someone performs by hand |

**How to run them without turning one audit into eight.** Run Red first — it produces the findings the
others react to. Blue, Yellow and Green can run in parallel; they share no state. Purple and Orange
are **derived** passes: they take Red's list as input and produce work items, so running them before
Red is finished produces nothing. White runs once per full loop, not per pass. Black is often a short
list of "not verifiable from here" — write it down anyway, because it is the surface that gets
skipped precisely because it is inconvenient.

**A pass that reports nothing is a result, but a suspicious one.** Red finding nothing on a feature
with real inputs usually means Red was polite. Blue finding nothing usually means nothing is
instrumented, which is itself the finding.

Security has its own reading of the same wheel — attack surface, access control, secrets, compliance
— and that belongs to **`/auto-audit-security`**. This skill's Red pass is about *correctness under
hostile conditions*, not exploitation. Do not do both here; hand security findings across.

## What "Finished" Means

The runtime path actually works on each target. Not that it compiles. Not that the UI renders. Not
that a comment says it works. Not that a test double returns the right shape. Not that it works on
your machine.

Watch for the recurring shape — code that passes compile, launch, and smoke test while moving zero
data:

- a class registered against an interface whose method silently returns nothing (`getNextFrame`
  returning `false` forever)
- a callback left null, wired nowhere
- a counter incremented on the wrong side of the failure, so metrics look healthy while nothing flows
- an error swallowed into a log line nobody reads
- a config path that silently falls back to a no-op backend
- a platform branch that compiles to an empty body on every target but the one you tested

Verification = run the real thing in the real environment for that target, read the logs, confirm
bytes/frames/events/rows actually moved. Quote the log line that proves it. What "real environment"
means per target:

| Target | Verified by |
|--------|-------------|
| Mobile OS | Physical device, driven, logs read. An emulator only where policy permits, and labelled as an emulator result |
| Desktop OS | The app running on that OS — not "it's the same Electron bundle" |
| Browser | Each supported engine, not only the one you develop in |
| Server / service | Deployed or containerized run hitting real endpoints, logs tailed |
| CLI | Invoked from a real shell on that OS, exit codes and stderr checked |
| Library / package | Consumed from a fresh install by a scratch project, not from the repo |
| Embedded / hardware | The board, powered, with the peripheral attached |
| Host you're on | Same standard as any other target — run it, don't inspect it |

## "It Doesn't Exist" Is The Start Of The Work

Capabilities declared impossible on real projects, all wrong:

- a library that "ships binaries for one platform only" — open source, so it cross-compiled to the
  rest
- a standard with "no SDK for this platform" — true, so the stack was written from scratch against
  the spec, one shared core across every target
- device metadata that "needs the vendor's database" — false, the devices serve it over the network

Before concluding a capability is impossible:

1. Look for prior art. **If any other software does it on this platform, it is a research problem,
   not a wall.**
2. Check whether the blocking component is open source, reimplementable, reachable by another
   protocol, or replaceable by a native equivalent on that platform.
3. Only then report a genuine platform limit — explicitly, with evidence (the API that doesn't exist,
   the entitlement that isn't granted, the syscall the sandbox denies, the doc that says no).

**Never degrade quietly.** Silently shipping a lesser version is worse than saying it can't be done.

## Rationalization Table

| Excuse | Reality |
|--------|---------|
| "Last pass found nothing serious, we're done" | "Nothing serious" ≠ nothing. Run the full pass. |
| "It compiles and launches" | Compiling is not working. Verify data actually moves. |
| "The UI renders, so it works" | UI renders fine over a dead backend. Read the logs. |
| "Verified on one target, the others run the same code" | They don't. Build and verify each. |
| "It's cross-platform, so it's platform-agnostic" | The runtime under it isn't. Run it on each. |
| "It works on my machine" | Your machine is a target, not a proxy for the others. |
| "The host platform obviously works, I've been building on it" | Building is not running. Verify it. |
| "No SDK exists for this platform" | Prior art check first. Others shipped it somehow. |
| "This is a platform limitation" | Prove it with the specific missing API, or keep working. |
| "I'll note this as a known limitation" | That's quiet degradation. Fix it or get explicit sign-off. |
| "The remaining items are minor polish" | List them. If they're real, they're work. |
| "Tests pass" | Tests pass against mocks. Real environment or it didn't happen. |
| "I can't test that target" | Emulator, VM, container, CI runner first. Then report unverified. |
| "I'm running low on context" | Save state to memory, continue after compaction. Don't stop. |
| "Good enough to ship" | Shipping is the user's call, not yours. Report, don't push. |

## Red Flags — Keep Working

- About to say "complete", "done", or "ready" without a log line proving the runtime path
- About to say "impossible" or "not supported" without naming the specific missing API
- Verified one target, extrapolated to the rest
- Never wrote down the target list, so "every platform" has no definition to check against
- Counted the host platform as done because you've been building on it all session
- Ending a session on a pass that found nothing, after only one pass
- Writing "known limitation" into docs instead of into a conversation with the user
- Pushing, tagging, or submitting without explicit approval

## Quick Reference

| Stage | Done when |
|-------|-----------|
| Targets | Written list of every platform shipped to, host included |
| Audit | Every claimed feature mapped to a file:line runtime path, per target |
| Fix | No stubs, no silent no-ops, no deferred TODOs |
| Build | Green on every target |
| Verify | Run in each target's real environment, logs quoted showing data moved |
| Review | Adversarial pass found nothing new on any target |
| Media | Stale assets listed |
| Ship | User approved, explicitly, this time |

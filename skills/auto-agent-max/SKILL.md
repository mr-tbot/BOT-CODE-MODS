---
name: auto-agent-max
description: "Use when the user wants the ceiling off subagent spawning — they say \"/auto-agent-max\" (optionally followed by a number capping how many subagents), ask for maximum capability, peer-tier subagents, no model downgrade, or the best possible result regardless of cost. Removes the tier cap so the orchestrator may spawn same-tier subagents, while still sizing each one to the task."
---

# /auto-agent-max

Remove the tier ceiling. A subagent may run the same model as the orchestrator when the subtask
genuinely warrants it.

**Usage:** `/auto-agent-max` — the agent count is yours to judge.
`/auto-agent-max 10` — a hard ceiling of ten subagents.

## What This Changes, And What It Does Not

It changes exactly one thing: **the cap**. From the top tier you may now spawn peers, which
`/auto-agent-eco` forbids.

It does not change the routing discipline. "Max" is not "put everything on the biggest model" — that
is not maximum capability, it is maximum spend with a side of latency. A top-tier agent sent to run
`grep` across a directory returns the same answer as a cheap one, slower and dearer, and having four
of them queued behind a rate limit is *worse* than the eco version that finished.

So the question every subagent still has to pass is the same one: **what does this task actually
need?** The difference is only that "the top tier" is now an available answer instead of a forbidden
one.

## When A Peer-Tier Subagent Is Genuinely Right

Reach for one when the subtask carries the same difficulty as the orchestration:

- **Adversarial verification of a consequential claim.** Whatever tries to refute a finding should be
  at least as capable as whatever produced it. If a top-tier agent found it, a top-tier agent should
  attack it.
- **Independent attempts at a hard design**, where the value is genuine diversity of approach rather
  than parallel throughput. Three peers reasoning separately, then judged, beats one attempt iterated
  when the solution space is wide.
- **Deep reasoning over unfamiliar territory** — an undocumented protocol, a subtle concurrency
  defect, a build system misbehaving for non-obvious reasons.
- **Work whose failure is expensive and quiet**: security review, licensing judgments, anything that
  ships and misleads if it is wrong.

## When It Is Still Wrong, Even Here

- Locating code, inventorying files, running builds, applying a stated edit — these do not improve
  with a better model, and the queue they create is a real cost.
- Anything where the answer is verifiable by execution. Let something cheap produce it and let the
  test say whether it is right.
- Padding a fan-out to look thorough. Six peers on a three-agent problem is not rigour, it is six
  agents rediscovering the same context and then disagreeing about it.

## Peer Agents Change The Merge

A cheap subagent that goes wrong is usually *obviously* wrong. A peer-tier one that goes wrong is
**plausibly** wrong — same fluency, same confident tone, same shape of evidence as a correct answer.
That makes contradictions between peers harder to spot, not easier.

So the orchestrator's job gets harder rather than easier as the tiers rise:

- Read peer results **against each other**, not in sequence. Two peers reaching different conclusions
  from the same code is the most valuable signal a fan-out produces, and it is invisible if you merge
  them one at a time.
- When peers disagree, **resolve it against the source**, not by preferring the better-written answer.
- Never treat agreement between peers as verification. Two agents given the same prompt and the same
  context are correlated, not independent, and they can be confidently wrong together. If independence
  matters, vary the lens: give each a *different* angle of attack rather than the same brief.

## The Agent Count

A number after the command is a **hard ceiling**: `/auto-agent-max 10` means never more than ten,
regardless of how the work decomposes.

With no number, choose from the work and say why. Two things still bound it, and neither is loosened
by this skill:

- **Resource limits are not negotiable by a capability policy.** If `/auto-balance` has sized this
  session, that number is a ceiling. Peer-tier agents are heavier per agent, not lighter — on a
  contended machine or against account limits, max mode reaches the wall *sooner* than eco does.
- **Rate and usage limits are real.** A fan-out that exhausts the session's budget partway leaves the
  work half-done, and half a review is worth much less than a completed smaller one. If the budget is
  tight, prefer fewer peers over more, and say that is what you did.

## Report The Spend

State the fan-out: how many subagents, at which tiers, and why each peer-tier agent needed to be one.
"It was max mode" is not a reason. If the answer would have been the same at a lower tier, that agent
was waste and is worth naming, because the next run can be cheaper for free.

## Rationalization Table

| Excuse | Reality |
|---|---|
| "Max mode, so everything runs top tier" | Max removes the ceiling; it does not remove routing. A grep is still a grep |
| "More peers means more rigour" | Past the point the work decomposes, it means more agents rediscovering the same context |
| "Both peers agreed, so it's verified" | Same prompt, same context — correlated, not independent. Vary the lens or do not claim verification |
| "The better-written answer is the right one" | Fluency is not correctness, and at this tier both are fluent. Resolve against the source |
| "No ceiling given, so spawn as many as decompose" | `/auto-balance` and the account limits still bound it. Max mode hits them sooner |
| "It's max mode, cost isn't a concern" | Then say what it cost. The user chose capability, not ignorance of the bill |
| "A peer can do the merge" | The merge is where peer contradictions surface. That is the orchestrator's work |

## Red Flags — Stop

- Assigning top-tier agents to mechanical work because the ceiling is off
- Treating peer agreement as verification
- Merging peer results sequentially instead of against each other
- Exceeding a user-supplied ceiling, or overriding `/auto-balance`'s number
- A fan-out that exhausts the budget and leaves the pass unfinished
- Reporting the result without reporting what the fan-out actually cost

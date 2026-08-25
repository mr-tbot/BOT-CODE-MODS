---
name: auto-agent-eco
description: "Use when the user wants subagents spawned economically — they say \"/auto-agent-eco\" (optionally followed by a number capping how many subagents), ask to keep agent costs down, to orchestrate cheaply, to use cheaper models for the legwork, or to stop defaulting every subagent to the heaviest model. Sets the model-tier policy for a fan-out: the orchestrator stays top tier and every subagent runs strictly below it."
---

# /auto-agent-eco

Spawn subagents one tier *below* the model doing the orchestrating. The expensive model decides,
routes and merges; cheaper models do the legwork.

**Usage:** `/auto-agent-eco` — the agent count is yours to judge.
`/auto-agent-eco 6` — a hard ceiling of six subagents.

## The Rule

Read the model this session is running as, then cap every subagent strictly below it:

| Orchestrator | May spawn | Never |
|---|---|---|
| Fable | Opus, Sonnet, Haiku | Fable |
| Opus | Opus, Sonnet, Haiku | above Opus |
| Sonnet | Sonnet, Haiku | above Sonnet |
| Haiku | Haiku | anything above |

Note the asymmetry: from Fable, the ceiling drops a full tier — that is the entire point of eco mode,
and it is where the saving comes from. From Opus and below, "strictly below" would leave nothing
useful to route to on hard subtasks, so same-tier is permitted and the discipline becomes *routing*
rather than *capping*. Do not spawn a peer out of habit; spawn one when the subtask genuinely needs
that tier.

If the session's model cannot be determined, assume the tier below your best guess and say which
assumption you made. Guessing high spends the user's money on an assumption they never agreed to.

## Where The Saving Actually Comes From

Not from making everything cheap. From splitting the work by *kind*:

- **The orchestrator keeps the judgment** — deciding what the subtasks are, spotting when a result is
  wrong, reconciling contradictions, and writing the synthesis. That work is dense, short, and the
  worst possible thing to hand to a cheap model.
- **Subagents get the volume** — reading files, tracing call sites, running greps and builds, drafting
  mechanical edits, gathering evidence. That work is long, parallel, and mostly legwork.

A pass that hands twelve files to a cheap model and one paragraph of conclusions to the expensive one
costs a fraction of a uniform fan-out and loses very little. A pass that hands the *conclusions* to
the cheap model saves nothing worth having, because the orchestrator then re-does the thinking.

## Routing, By What The Task Actually Needs

| Task | Tier |
|---|---|
| Locating code, mapping call sites, inventory, "where is X" | Lowest that can read reliably |
| Mechanical edits with an exact spec — renames, formatting, applying a stated change | Low |
| Routine implementation against a clear brief, test writing, doc drafting | Middle |
| Tracing a defect through unfamiliar code, protocol work, anything needing a hypothesis | High (still below the orchestrator) |
| Adversarial verification, security review, "is this claim actually true" | **Do not economise. See below** |
| Synthesis, contradiction-resolution, the final call | The orchestrator itself, not a subagent |

## What Eco Mode Must Not Downgrade

Cheap models fail in a specific way: they produce output with the *shape* of a correct answer. A
plausible file:line that does not exist, a confident "verified" with nothing behind it, an edit that
compiles and does the wrong thing. That failure mode is invisible to a merge that trusts its inputs.

So three things stay expensive regardless of budget:

1. **Adversarial verification.** If a finding is going to be acted on, whatever tries to *refute* it
   must be at least as capable as whatever produced it. Cheap verification of cheap work is theatre.
2. **Security and correctness judgments.** "Is this exploitable", "does this actually hold" — wrong
   answers here cost far more than the tokens saved.
3. **The merge.** The orchestrator reads every subagent result critically and never pastes them
   together. A contradiction between two subagents is a finding, not a formatting problem.

**Eco means cheaper, not credulous.** If economising would mean shipping an unverified claim, spend
the tokens or report the claim as unverified — the third option, quietly lowering the standard, is
the one this skill exists to prevent.

## The Agent Count

A number after the command is a **hard ceiling**: `/auto-agent-eco 6` means never more than six, and
it wins over your own judgment.

With no number, choose from the work and the machine, and say what you chose and why. Two constraints
bound it and the tighter one wins:

- **Resource limits are not negotiable by a cost policy.** If `/auto-balance` has sized this session,
  its number is a ceiling this skill cannot raise — a cheaper model still occupies a slot, still
  contends for the same machine, and still counts against account limits. Eco mode reduces cost per
  agent; it does not create capacity.
- **Fewer, longer-lived agents beat many short ones**, for coherence and for limits. Splitting one
  coherent investigation across six agents costs more than it saves, because each rediscovers the
  same context.

## Report What The Policy Cost

At the end, state the fan-out honestly: how many subagents, at which tiers, and — this is the part
that matters — **anything you routed to a cheaper tier that you would have given a better model with
no budget.** That is the user's information, not yours to absorb silently. If a cheap agent's output
looked thin and you accepted it anyway, say so.

## Rationalization Table

| Excuse | Reality |
|---|---|
| "Eco means use the cheapest model everywhere" | It means route by task. Cheap synthesis costs more than it saves |
| "The subagent said it verified it" | A cheap model asserting success is the failure mode, not the evidence |
| "I'll have a cheap agent check the cheap agent's work" | Verification must be at least as capable as what produced the claim |
| "Same tier is fine, it's only one subagent" | From the top tier that is exactly what eco forbids. Drop a tier or justify it out loud |
| "Cheaper agents, so I can run more of them" | Cost per agent fell; the machine and the account limits did not move |
| "I don't know what model I'm running, I'll assume the top" | Assume lower and say so. Guessing high spends money nobody approved |
| "Merging is mechanical, a subagent can do it" | Merging is where contradictions surface. That is the orchestrator's job |
| "I saved a lot of tokens" | Say what it cost in confidence, too. A cheap pass that missed things is not a saving |

## Red Flags — Stop

- Spawning a peer-tier subagent from the top tier, which is the one thing eco mode forbids
- Verifying cheap output with something equally cheap
- Pasting subagent results together instead of reading them against each other
- Exceeding a user-supplied ceiling, or treating `/auto-balance`'s number as advisory
- Reporting a clean result without saying which parts ran on a downgraded model
- Downgrading a security or correctness judgment to save tokens

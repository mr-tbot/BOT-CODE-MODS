---
name: auto-media-onboarding
description: "Use when a project's first-run onboarding video — the one a new user watches before they know what anything does — needs making or bringing back in line with the current first run; when the user mentions the onboarding video, the welcome video, the getting-started clip, first-run, or the walkthrough new users see, or says \"/auto-media-onboarding\"; or when signup, install, permissions or the first screen has changed and the video still teaches the old path."
---

# /auto-media-onboarding

One deliverable: **the onboarding video.** The film that takes a stranger from nothing to their first
real outcome in the product.

`/auto-media-maker` owns the series and the staleness tracker. `/auto-media-stinger` owns the launch
commercial. This owns one film, and is held to standards neither of them is.

## What This Skill Inherits

Read from `/auto-media-maker`, never re-asked: pipeline discovery and `.agent/media.json`, avatar and
voice, the brand folder, the verbatim `never_say` list, the catalog, the `watch`/`on_change`
machinery, per-line content-addressed narration, `vN` filenames, blessing, and the memory entry
format. Its capture hygiene is law here — scripted drive, no hand-scroll, cursor hidden, UI settles
before and after every action.

If none of that exists, bootstrap only what this film needs — pipeline discovery, avatar and voice
from the real account listing, brand folder, `never_say`, the *tutorial* style set, plus the demo
account and capture rig, which this film cannot be shot without. Write one catalog entry, record that
the rest of the series is **unplanned** rather than skipped, and say so in one line: "run
`/auto-media-maker` when you want the catalog." Offer; do not perform.

**Never plan a catalog here, never build a second config or task list, never re-ask the parent's
interview.**

## Step 1 — Name The First-Value Moment, Before A Word Of Script

The film is not done when it has explained the product. It is done when a stranger who watched it has
**the outcome in front of them.** Write that as one sentence, in this shape, at the top of the shot
list:

> A new `<role>` now has `<a concrete artifact or observable state>` that the product produced, which
> they did not have before, and they can see it.

"Understands the dashboard", "has explored the workspace", "knows what we do" are all failures — none
is observable. These are the shape:

| Product | First-value moment |
|---|---|
| Log/analytics tool | Their own first line of real log data is visible in the live tail |
| CI product | A green check appears on a commit they just pushed |
| Invoice SaaS | An invoice PDF exists and is downloadable |
| Video/VJ tool | The first output frame renders on the second screen |
| Home-server appliance | The device answers on its LAN address from their own browser |
| API product | A 200 comes back from their own key, in their own terminal |

**Build backwards from it.** Write the last shot first. Then walk backwards asking of every candidate
beat: *does a viewer who skips this fail to reach the last shot?* If no, cut it. That single rule
kills the feature tour, the pricing tiers, the founder's why, the settings panel, the integrations
grid and the nav walkthrough. Those belong to the series.

Two conditions of done, both required: the film **ends on the first-value moment held on screen** —
not a CTA card, not a logo, not "check out our docs" — and everything in it is on the critical path.
The critical path's length is the film's length.

**If you cannot name the moment in one sentence, stop and get it named.** A product without a defined
first-value moment cannot have an onboarding video; it can only have a tour, which is a different
deliverable.

## Step 2 — Why This Is The Most Conservative Film In The Catalog

Every other product video is watched by the already-curious. This one is watched by people mid-decision,
with the product open in the next tab, at the moment their patience is lowest. Three consequences:

- **It is the only video with a live cost of being wrong.** A stale marketing video is embarrassing; a
  stale onboarding video is a support queue, and the tickets come from the users who were trying
  hardest. "The video says X, the app does Y" is a P2 bug, not a content backlog item.
- **It is watched by people who are already stuck**, scrubbing for the step they are on. Seekability,
  chapters and honest timing are functional requirements, not polish.
- **It is watched twice** — once to decide, once to follow along, paused. The second viewing decides
  whether it worked, and it is unforgiving of anything faster than a human hand.

So, explicit bans:

- **No speed ramps, no time-lapse, no 2× "for pacing".** If a step takes 40 seconds, hold the 40
  seconds, or state the honest duration and cut to completion. Faking speed makes viewers think they
  have broken something when their machine takes the real time — the single most common cause of "is
  it stuck?" tickets.
- **No push, parallax or drifting zoom on the UI.** The viewer is comparing your frame to their screen
  pixel-for-pixel and motion breaks the comparison. Zoom only as a hard cut to a static labelled crop,
  only when the target is genuinely unreadable at delivery resolution.
- **No music bed under instruction.** Under the cold open and outro is fine; under a spoken
  instruction it costs intelligibility for non-native speakers and anyone running captions with audio.
- **One action per shot.** Cursor arrives, pauses ~0.3s, acts, and the resulting state is **held at
  least 2 seconds** before the cut. The hold is the viewer's checkpoint against their own screen.
- **Never cut away from a state change.** If the click changes the screen, the change happens on
  screen, in one take, uncut.
- **No shot over ~20s without a visible state change** — a frozen screen reads as a stall and the
  viewer scrubs past the narration.
- **Real cursor, deliberate movement.** No teleporting pointer, no click sound without a visible
  click, no jump cut hiding a mis-click. Re-take the shot.
- **No stock footage of people at laptops.** That is the stinger's vocabulary; here it burns seconds
  that carry no instruction.

The mood is *calm competence*. If it feels slightly slow to the person who made it, it is probably
right for the person who has never seen the product.

## Step 3 — The Beat Map

| # | Beat | Length |
|---|---|---|
| 0 | **Cold open on the outcome** | 3–8s |
| 1 | **The promise** — what you will have, and when | 5–10s |
| 2 | **The gate** — install / account / permissions | 0–45s, chapter break both sides |
| 3 | **The spine** — the critical path | bulk of runtime |
| 4 | **The moment** — first value, held | 8–15s |
| 5 | **The handoff** — one next step, one place | 10–15s |

**You do not start at the signup form.** That is the default mistake and it loses both audiences that
matter: the evaluator, who wants to see the payoff before investing, and the returner, who already has
an account. Open on the finished outcome instead — the green check, the rendered frame, the live data.
No logo sting first. It is the contract: *this is where you will be at the end.*

**The promise, stated honestly.** "In about four minutes you'll have X. You'll need Y." Name the
prerequisites out loud *and* on screen — an account, admin rights, a domain, a device on the same LAN,
a card for the trial. Naming them up front converts a would-be failure into a viewer who comes back
prepared. **Never hide a prerequisite until the beat where it blocks them.**

**The gate is where you lose everyone.** Chapter break before and after it, because half the audience
already did this and needs a marker to skip, and the other half needs one to come back to.

- **Never show a progress bar in real time.** Over ~30s, state the honest duration and cut to the
  completed state. Hold the *success indicator* long enough to compare against their own.
- **Show the verification email arriving** — sender name, actual subject line, where it lands.
  "I never got the email" is a top-three first-week ticket for nearly every product, and four seconds
  naming the sender and mentioning the spam folder eliminates it.
- **Permissions and consent dialogs are never skipped.** OS prompts (microphone, camera, screen
  recording, accessibility, notifications, location), OAuth scope screens, admin/UAC/sudo, cookie
  modals. These are exactly the dialogs that look alarming, differ per OS version, and get cancelled.
  Show each one, name what it is for, show the state after granting. **A cancelled permission is the
  most expensive silent failure in software onboarding.**
- **Platform forks live in their own chapter, not in the spine.** Pick one canonical platform for the
  spine — the one most new users are actually on; check, do not assume — and put the others in short
  parallel chapters. Interleaving "on Windows… on Mac… on Linux…" makes every viewer sit through
  two-thirds of instructions that do not apply, and triples the film's honest length.
- **Never demo an install with warnings suppressed or a security prompt bypassed.** If the real flow
  shows a Gatekeeper or SmartScreen warning, show it and explain it. Editing it out teaches users to
  expect a smooth path and makes the real one look like malware.

**The spine.** Each beat: *state the goal → name the control → act → show the result → confirm.* Say
what you are about to do before doing it; the viewer following along needs the warning to keep up.
Number the beats on screen past four (`Step 3 of 6`) — it converts an unknown-length ordeal into a
countable one and gives support a shared vocabulary ("you're stuck at step 4").

**Chapter breaks belong at the product's recoverable states, not at your script's topics.** A chapter
boundary is a place where a viewer could stop, close the laptop, come back tomorrow and resume without
redoing anything: after install, after account and verification, after the first config persists, at
first value. **If a chapter does not correspond to a durable state in the product, it is a heading —
cut it.**

**The moment.** Hold it. Say what happened in plain language ("that's your data, live"). Do not layer a
CTA over it; give the viewer the seconds it takes to feel it worked and check their own screen.

**The handoff: exactly one next step and one place to get help**, the URL on screen *and* spoken. Not
five links, not "join our Discord and read the docs and follow us and book a demo". One.

## Step 4 — Length, Honestly

| Case | Target | Ceiling |
|---|---|---|
| Spine only, product already installed | 90s – 3min | 4min |
| Full path including the gate | 3 – 5min | 6min |
| One part of a series | 2 – 4min | 5min |

Wistia's State of Video — the largest public dataset here, the 2026 edition covering over 13 million
videos and 79 million hours — reports engagement falling with length: roughly ~60% under five minutes,
~45% at 5–30 minutes, ~35% at 30–60. The 2025 edition's finer buckets: under 1min ≈ 50%, 1–3min ≈ 46%,
3–5min ≈ 45%. Tutorial content holds up best of any category.

State two caveats whenever you cite that: it is **observational engagement across all content on one
platform**, not a controlled experiment on onboarding films; and the five-minute inflection is a soft
cliff, not a rule. **The causal constraint is the product's honest time-to-first-value, not a video
industry average.** If the critical path exceeds six minutes after everything off it has been cut, the
problem is the product's first-run flow, not the edit — say so in the report rather than compressing
the film into a lie.

**Split into a series if any of these is true:** there are two or more legitimate "done for now"
stopping points where the product genuinely persists state; the gate exceeds ~45 seconds or forks
across platforms; personas diverge (the admin who connects the data source is not the analyst who
reads it — two audiences, two films, never one film asking each half to sit through the other's work);
or the honest path still exceeds six minutes. **Do not split for pacing or for more content** — that
is the series' business, and a gratuitous split makes the viewer hunt for part 2 at the moment they
are least motivated.

**Name parts by outcome, with an ordinal**, because "Onboarding 2" is unfindable and unpasteable:

```
Getting started 1 · Install and sign in
Getting started 2 · Connect your first data source
Getting started 3 · Read your first report
```

The outcome phrase must match what a stuck user would type into search *and* what a support agent
would paste into a reply; it must match the docs page heading and slug; and it must survive being read
aloud over the phone. **One string, five places**: video title, chapter marker, docs heading,
transcript filename, in-product help link.

## Step 5 — The Demo Environment

**One seeded, deterministic demo account, created by a checked-in script** — not an account someone
hand-curated once.

- `seed.sh` is **idempotent and resettable** (`--reset` returns it to shot-zero), lives beside the shot
  list, and runs immediately before every capture.
- **Determinism includes time.** Freeze the clock or generate dates relative to run time, so "3 days
  ago" still reads correctly in a re-shoot six months later. Hardcoded dates date the film instantly.
- **Determinism includes ordering.** Fixed sort orders, fixed IDs where the UI shows them, no random
  sample data — a re-shot single shot must intercut with the old footage.

**Real data and real production writes are forbidden. No exceptions, not "just this once, it's my own
account".** No customer data ever, not anonymised, not internal-only — a single frame is a
publication, and video is the one medium where people go looking for leaked frames. Never demo a
destructive action against anything real; never let the demo send a real email, SMS, push, webhook,
invoice or payment — use a catch-all mailbox, a request bin you control, and test-mode keys. No real
credentials on screen, including for one frame during a paste, in terminal scrollback, an autocomplete
dropdown, URL history, a bookmarks bar, a notification or a tab title. **Assume every frame is
inspected, and rotate anything that appears anyway.**

Placeholder identities that are documented-safe:

| Kind | Use | Authority |
|---|---|---|
| Domains | `example.com/.net/.org`, and `.test`, `.example`, `.invalid`, `.localhost` | RFC 2606 |
| Phone (NANP) | **only** `555-0100`–`555-0199` | NANPA — the rest of the 555 range was returned to inventory and is assignable, so `555-1234` is **no longer safe** |
| IPv4 | `192.0.2.0/24`, `198.51.100.0/24`, `203.0.113.0/24` | RFC 5737 |
| IPv6 | `2001:db8::/32` | RFC 3849 |
| Cards | Only the processor's published test numbers, in test mode — e.g. Stripe `4242 4242 4242 4242` | Stripe testing docs; their agreement **prohibits live-mode testing with real payment details** |
| People | Invented names + `example.com`; generated or licensed avatars, never a colleague's headshot without a release |  |

No third-party logos or brand names in seeded data — trademark exposure, and it dates and localises
badly.

**Repeatability is the highest-leverage investment in this skill**, because the alternative to
re-shooting one shot is re-shooting the film. Check in a capture spec: exact resolution and OS/browser
scaling (mismatched DPI makes an intercut shot obviously different), fixed window geometry, a
dedicated capture profile with no extensions, no bookmarks bar and no personal history, default zoom,
notifications off, fixed light/dark mode and accent, fixed cursor size and font rendering, mic and gain
noted. In the same file record the **build identity of the take** — app version, commit hash,
environment, date. That one line is what makes staleness decidable later instead of a judgement call,
and it is the line the parent's tracker consumes.

Shots are atomic — no motion or narration phrase crossing a cut. Narration is a separate track, never
baked into the screen recording. Callouts live on a separate overlay layer. Archive the project file
and raw captures, not just the export.

## Step 6 — Accessibility Is A Ship Blocker Here

This is the one video where inaccessibility means *cannot use the product*, not *missed some
marketing*.

- **Captions authored or human-corrected, never shipped auto** — WCAG 2.2 SC 1.2.2 (Level A), covering
  dialogue plus speaker identification and meaningful non-speech sound. Auto-captions fail precisely
  on the tokens carrying the instruction: product names, CLI flags, filenames, URLs, version numbers,
  casing. **Every UI string, command, path and URL in the caption file is diffed character-by-character
  against the current build** — that check is scriptable and belongs in CI.
- **Caption form**: ≤42 characters per line, maximum 2 lines, reading speed ≤20 cps for adult English
  (Netflix English Timed Text Style Guide); BBC guidance targets 160–180 wpm with a minimum of roughly
  0.3s per word on screen. **If narration cannot be captioned inside those limits, the narration is too
  fast for an instructional film — slow the VO, do not compress the caption.** The FCC's four caption
  quality tests (47 CFR § 79.1(j)(2)) — accuracy, synchronicity, completeness, placement — are the right
  review rubric, especially placement: **captions must not cover the UI element being taught.**
- **A transcript that describes the visuals.** A dialogue-only transcript is not a valid alternative;
  SC 1.2.3 asks for a full text alternative for the time-based media, which includes what happens on
  screen. Write it as a numbered written quickstart and it doubles as the docs page, the
  search-indexable artifact, and the thing support pastes into tickets. Best ROI in the deliverable set.
- **Audio description** (SC 1.2.5, AA). Preferred route: **integrated self-describing narration** —
  write the script to state what changed ("the row turns green and a Deploy ID appears in the header")
  and no separate track is needed. Fall back to a real AD track when the UI does more than the
  narration gaps can carry. **Record the choice explicitly**; "we decided narration carries it" is a
  claim you must be able to defend.
- **Burned-in text contrast ≥4.5:1** (≥3:1 for large text) — SC 1.4.3 — measured against the actual
  frames behind it across the shot's full duration, not a static mock. Use an opaque or scrimmed plate.
  Burned-in text is an image of text (SC 1.4.5), so anything essential also exists in the captions or
  transcript.
- **No instruction that depends only on colour or only on position** — SC 1.3.3 and 1.4.1. Never "click
  the green button" or "the icon in the top right" alone. Name the control first, colour and position
  second: "click **Connect source** — the green button top right." Same for results: "the status turns
  green **and reads Connected**." Never identify anything by count or order alone; lists reorder.
- **Nothing flashes more than three times per second** (SC 2.3.1) — a real risk when screen-capturing
  spinners and terminals.
- Embedded player: keyboard operable, captions on by default for this video, no autoplay with sound,
  and essential information never confined to the final frame — people navigate away on the outro.

## Step 7 — Localisation: Cheap Is A Script-Time Decision

The economics are simple: **cheap is new audio over the same picture; expensive is re-capture.**
Everything here is about staying on the left of that line.

**Cheap.** On-screen strings are tokens in the script (`{{ui.connect_source}}`) resolved from a UI
glossary kept as a separate file — the localiser swaps the glossary, not the script, terms stay
consistent with the localised product, and the tokens are diffable against the app's own i18n catalogue,
which also catches drift in English. **Zero baked text in the picture**: every callout, lower third and
step counter on a replaceable overlay track, one file per language; the only burned-in text is
genuinely language-neutral — a keyboard shortcut, a number, a version string. **Timing headroom**: cut
each shot so the English narration ends ≥0.5s before the cut, because translations into German,
Finnish, French or Spanish routinely run longer (plan for roughly +15–30% for Western European targets
— a production rule of thumb, not a measurement), and a picture cut tight to English VO breaks in every
one of them. Narration describes function, not phrasing: "give the workspace a name" survives a UI copy
change and a translation; "type in the box that says *Untitled workspace*" survives neither. No numbers,
dates, currencies or units spoken as fixed strings; no puns or idioms that need a re-write rather than
a translation. **No lip-sync, no on-camera presenter mouthing the words** — that alone is often the
difference between a modest re-voice and a full re-shoot, and it is another reason the presenter-led
format belongs to the stinger.

**Expensive** — avoid, or accept knowingly and write it down: any shot where the UI language is visible
and the narration reads it aloud (forces a full re-capture per locale); baked callouts, step counters
or kinetic typography; narration cut tight to picture; music stings synced to word boundaries; seeded
demo data containing English prose that appears on screen while being discussed.

**The one genuine tension.** Accessibility demands you name the control; cheap localisation prefers
narration that never speaks an on-screen string. **Accessibility wins.** Keep it cheap by *tokenising*
the name and building timing slack — not by going vague. "Click the button on the right" is both
inaccessible and no cheaper.

## Step 8 — Parity With In-Product Onboarding

The video and the product's first-run flow are two implementations of one contract, and must agree on
all five of: the named first-value moment; the order and count of steps; the exact strings of every
primary CTA the narration names; the default state of a brand-new account (what is pre-seeded, what is
empty, which modal fires first); and the claimed duration.

Register the video as a **downstream consumer of the first-run flow** — a CODEOWNERS entry on the
onboarding route, the signup handler and the first-run i18n keys, pointing at the media project, plus
the CI string diff from Step 6, so a copy change fails a check instead of being discovered by a user.

**Decide re-shoots by this ladder, not by feel:**

| Severity | Trigger | Action |
|---|---|---|
| Cosmetic | Colour, icon, spacing, non-narrated copy | Log it; fold into the next batch |
| Copy | A string the narration or captions name has changed | Patch caption and transcript, pin a correction note, re-shoot the shot next batch |
| **Structural** | A step added, removed or reordered; a new required field, consent modal or plan chooser; the first-value moment itself changes | **The video is now wrong. Pull it or replace it** |

**Pulling is legitimate and often correct.** A missing onboarding video costs a support link. A lying
one costs a failed activation, a ticket, and the user's trust at their most fragile moment. When the
flow changes structurally and a re-shoot is a week out, replace the embed with the transcript-derived
written quickstart and ship the film when it is true.

## What `check` Cannot See

**A sequence can break with no file changing** — a step reordered, a permission prompt now appearing
earlier, an email verification added. The parent's fingerprint will report clean. So this film's own
staleness trigger is to **re-walk the real first run on a clean account** periodically, not to trust
the diff. Its `watch` map is the densest in the project: one beat per screen of the real first run,
each watching the source files that render that exact screen.

## The Pass/Fail Test

**The only test that counts: five people who have never used the product, each on their own machine
with a clean account, following only the video** — no help, no docs, no one in the room answering
questions. Screen-record with consent, and time them.

- **Pass = reached the named first-value moment unaided.** Not "seemed to get it" — the artifact exists
  or it does not.
- **Bar: 4 of 5 succeed, and the failures are different failures.** Two people failing at the same beat
  is not bad luck; that beat is the defect, and it is usually a skipped permission dialog, an unstated
  prerequisite, or a faked duration.
- **Median completion time ≤ ~3× runtime.** Beyond that the film is understating the difficulty, which
  is its own kind of lie and its own ticket generator.
- Log every question a participant *wanted* to ask. Each is a missing sentence.

**Proxy tests when five strangers are not available** — run all four, they are cheap:

1. **Cold rebuild.** One person from another team, a genuinely fresh machine and a brand-new account,
   following only the video. Not the author, not anyone who has seen the flow this quarter. Catches
   most of what a real user test catches, at a fraction of the cost.
2. **Mechanical parity, automated.** Every UI string spoken or captioned exists in the current build's
   i18n catalogue; every URL shown returns 200; the seed script runs green against the current schema;
   the recorded build identity is within N releases of production.
3. **Mute-and-follow.** Sound off, captions on. If you cannot complete the task, the visual instruction
   is incomplete — which is the SC 1.2.5 / 1.3.3 check in disguise.
4. **The support-ticket read.** Sample the last 50 first-week tickets. Every recurring one is a beat the
   film skipped or lied about. Highest-signal maintenance input this skill has.

**Fail closed: if the film has never been run past someone who had not seen the product, it is a draft,
not a shipped video.** Say that in the report rather than shipping quietly.

Then the inherited law, with this film's own definition of watching properly: **never bless a build you
did not watch end to end with sound** — and watch it as a new user would, against a clean account, with
the actual current build open beside it.

## Rationalization Table

| Excuse | Reality |
|---|---|
| "The screens didn't move, the flow is fine" | Walk it on a clean account. A reordered step moves no file |
| "It's fine, it just skips the email verification now" | That is the step people get stuck on. Structural change means pull or replace |
| "Speed it up, the install is boring" | Faking duration is what generates "is it stuck?" tickets |
| "We'll start at the signup form" | You just lost the evaluator and the returner |
| "The permission dialog is obvious" | It is the most expensive silent failure in software onboarding. Show it |
| "Auto-captions are close enough" | They fail on exactly the tokens that carry the instruction |
| "One quick zoom to make it feel alive" | The viewer is comparing your frame to their screen. Motion breaks that |
| "I'll use my own account, it's not customer data" | A frame is a publication. Frame-stepping exists |
| "The video's a bit wrong but better than nothing" | A lying onboarding video costs an activation and the trust. Pull it |
| "We tested it — the team watched it" | The team cannot un-know the product. It has not been tested |

## Red Flags — Stop

- Shipping without one person who had never seen the product completing the flow from the video alone
- Any speed ramp, time-lapse, or faked duration on a step the viewer must actually wait through
- A permission, consent or security dialog edited out of the gate
- Real customer data, a real credential, or a real production write in any frame
- Auto-captions shipped, or captions covering the UI element being taught
- A structural flow change left live rather than pulled or replaced

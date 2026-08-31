---
name: auto-media-stinger
description: "Use when a project's main stinger — the short launch commercial that plays before anything else — needs writing, cutting, or bringing back in line with what the product now is; when the user mentions the stinger, the launch ad, the trailer, the sizzle reel, the hype cut, the thirty-second spot, or says \"/auto-media-stinger\"; or when the name, price, tagline, platforms or hero screen has moved and the ad still sells the old product."
---

# /auto-media-stinger

One deliverable: **the stinger.** The 15–30 second launch spot that plays at the top of the landing
page, in the app-store preview slot, in a paid feed placement, and before a demo. One master timeline,
three renders, one poster frame, one ship gate.

If the request is "make the videos", that is `/auto-media-maker`. If it is "make *the* video — the one
that plays first", it is this one.

## What This Skill Inherits

`/auto-media-maker` owns the shared foundation and this skill reads it rather than re-asking:
pipeline discovery and `.agent/media.json`, the avatar and voice, the brand folder and its
anti-references, the verbatim `never_say` list, the catalog, the `watch`/`on_change` machinery,
per-line content-addressed narration, `vN` filenames, blessing, and the memory entry format. Its
capture hygiene is law here too — scripted drive, no hand-scroll, cursor hidden, never film production
writes, never show real customer data or a real card or a placeholder domain.

If none of that exists yet, **bootstrap only what a stinger needs and hand the rest back**: run the
parent's Step 1 pipeline discovery, pick an avatar and voice from the real account listing, get the
brand folder, capture the `never_say` list, and ask the *advertisement* style set only. Write one
catalog entry. Then say in one line: "The rest of the series is unplanned — run `/auto-media-maker`
when you want the catalog." Offer; do not perform.

**Never plan a catalog here, never build a second config, memory file or CLI, and never re-ask an
interview question the parent already answered.**

## A Stinger Is A Different Object

Four differences; every decision below falls out of them.

**It is the only piece allowed to be striking.** A tutorial that shows off has failed — the screen is
the subject and the edit should be invisible. A stinger has no such duty. This is the one place in the
whole media surface where rhythm, contrast, hard cuts, a real sound-design idea and a point of view
are correct. Striking means *composed*, not busy. But do not import the tutorial's restraint: a
stinger that looks like a well-behaved walkthrough has failed at its only job, which is to make
someone stop.

**It lands one idea; it does not teach.** If you cannot say the idea in six words — "your builds stop
breaking on Fridays", "one link, every device" — you have a trailer for a product nobody asked to see.
Feature lists are the failure mode. Three features in twenty seconds means the viewer remembers zero.

**It is judged in the first two seconds** — before the audio has finished fading in, and on a scrolling
feed before the viewer consciously registers that a video started. It must also survive being a static
thumbnail at 200px wide, because in half its placements that is what it is until someone taps.

**It is watched on mute.** That changes the structure, not just the finishing.

## The Beat Map

Written for a **20-second master**. Durations scale; the proportions do not.

| Window | Beat |
|---|---|
| 0.00–0.40 | **The hit.** One full-frame image, highest contrast in the piece. The product mid-action, or the problem it kills. Cut in on motion already happening. No logo. No fade from black beyond two or three frames |
| 0.40–2.00 | **Cold open completes.** One line, five words maximum, in the largest type the piece will ever use. The whole idea, stated flat. A subordinate clause means it is the wrong line |
| 2.00–6.00 | **The claim, shown not asserted.** Real UI, real motion, one continuous action long enough to read. One cut maximum — the first sustained shot is what makes the piece read confident rather than frantic |
| 6.00–13.50 | **Proof.** Two, at most three real product moments, 2.5–3.5s each. Each answers "and it actually does that?" rather than introducing something new. Four cuts is the ceiling; five reads as a template |
| 13.50–17.00 | **The turn.** The thing only this product does. One shot, one line, held longer than the proof beats — a deliberate deceleration. Ads that skip it feel like they stopped rather than ended |
| 17.00–20.00 | **The mark.** Product name, one clause of what it is, one destination. Nothing else |

**The final 1.5 seconds must be completely static** — no motion, no residual animation, no logo still
settling, no motion blur. It is the frame a paused player, a scrubbed timeline and a platform-generated
end thumbnail will show, and it is the viewer's only chance to actually read the name and the URL. A
logo still easing into place at 19.6s is a logo nobody read.

The mark holds exactly three things: **name, one clause, one destination** — a domain *or* a store
badge, not both. No social handles, no QR code fighting the URL, no "coming soon" plus a date plus a
badge. Anything added there is subtracted from all three.

**The first frame** must be legible at thumbnail size, must not be a logo, must not be black, and must
carry the highest contrast in the piece. A logo-first stinger is the most common failure in product
video: it spends the only two seconds you are guaranteed on information the viewer cannot use yet.

## Built For Mute

Assume a large share of feed plays are silent. (The widely-quoted 85% figure is old, vendor-sourced
and contested — do not cite it. The design rule does not need it: if a meaningful fraction of plays
are silent and the spot is incomprehensible silent, it is broken for that fraction.)

**The audio track is additive, never load-bearing.** Every idea must survive muted. Sound design adds
physicality, pace and polish; it may not carry a single fact. No voice-over saying something the
screen does not, no punchline delivered in audio, no comic timing that exists only in the mix.

A 20-second launch spot usually should **not** have a voice-over at all — a talking head is how a
stinger degrades into a short bad tutorial, and a talking avatar in one is a different deliverable
with a different name. If there is VO, **100% of it is burned in.** Not platform auto-captions: those
are positioned by the platform, land in the chrome zone, restyle themselves, and are absent entirely
when the file is embedded on your own landing page.

**Text hierarchy: at most two levels visible at once, one new text object at a time.** Primary text is
at minimum 1/18 of frame height (~60px in a 1080-tall landscape frame, ~106px in 1080×1920). That is a
floor. Secondary text is never below 1/28 of frame height and never below the family's regular weight.
Contrast against the *worst* frame it covers, not a still you chose — hold text over a scrim or a
solid unless you have checked every frame underneath.

**Dwell time: ~0.3s per word plus 0.4s to settle, minimum 1.2s**, longer if the viewer must also look
at something else in frame. Read every card aloud at natural speed while it is on screen; if you are
rushing to finish before the cut it is too short — and you already know the line, which the viewer
does not.

## One Master, Framed For The Crop

Master 16:9 at 3840×2160, or 1920×1080 if every source is a 1080 screen capture — **never upscale UI.**
Inside it, define a **protected column**: the centre 9:16-shaped region, 1080 wide in a 1920-wide
frame. Every load-bearing element — the idea line, the mark, the URL, the subject of every shot —
lives inside that column for the whole piece. Then 9:16 and 1:1 are *crops of the same edit*, same
cuts, same durations, same audio. **If a cutdown needs its own edit, the master was framed wrong**;
fix it upstream rather than opening a second timeline.

If the product's own UI is portrait, master vertical at 2160×3840 and derive landscape by extraction
plus a designed background. Letterboxing a landscape UI into 9:16 with blurred bars is the visual
signature of a lazy cutdown and everyone reads it instantly.

**Vertical safe areas.** Platform chrome eats the bottom third and the right rail. Working numbers at
1080×1920, current as of 2026 and shifting with every app release — a starting point, then verify on a
real device:

| | top | bottom | right |
|---|---|---|---|
| TikTok | ~140px | ~400px | ~180px action rail |
| Instagram Reels | ~100–250px | ~400px (caption/audio + interaction column) | interaction column |
| YouTube Shorts | title/status | ~250–320px | action rail |

Design to the intersection: roughly a **900×1400 box centred in 1080×1920** — about 12% to 72% of
frame height with ~17% margin each side. The single rule that saves the most re-cuts:
**never put the logo, the URL or the CTA in the bottom third of a vertical.** In vertical the mark
goes upper-middle; in 16:9 it goes lower-third. Those are different positions and the crop will not do
it for you — build the mark as two positioned variants in the master and switch by output.

**Deliverables from the one master:** ProRes 422 HQ master; H.264 High Profile 4.0 at 10–12 Mbps VBR
with AAC 256 kbps stereo at 44.1 or 48 kHz for store and web; a poster/first-frame still; a designated
end-frame still. **Pick one frame rate and never mix** — 60fps device capture conformed into a 24p cut
judders visibly on UI motion, and it is the kind of thing nobody can name but everybody sees.

## Loudness

**Target for a stinger: −14 LUFS integrated, true peak ≤ −1.0 dBTP.** If the same spot must also run
as a broadcast commercial, deliver a *separate* −23 LUFS (EBU R128, −1 dBTP) or −24 LKFS (ATSC A/85,
−2 dBTP) version. Do not try to satisfy both from one file; you will satisfy neither. LKFS and LUFS
are the same measurement under different standards bodies.

Platform normalization levels: YouTube ≈ −14 LUFS and it **never turns anything up**; Spotify −14
("Normal", with −11/−19 user options) and true peak below −1, below −2 if the master is louder than
−14; Apple Music Sound Check ≈ −16 with true peak never above −1. **TikTok, Instagram, Facebook and X
publish nothing** — independent measurement lands around −14 to −15, and TikTok's behaviour is
disputed and has changed more than once. Do not design around an unpublished number that moves.

**Why a hot master sounds worse — the argument to give when someone asks for it louder.**
Normalization applies negative gain only. Master at −9 LUFS and YouTube applies −5 dB: the viewer
hears a transient-crushed mix at exactly the same perceived loudness as everyone else. You paid the
whole cost of the loudness war and collected none of the benefit. A −14 master with intact transients
sounds *bigger* at the same normalized level, because the surviving peaks are what the ear reads as
impact. Verifiable, not taste: right-click a playing YouTube video → **Stats for nerds → content
loudness**; **0.0 dB means you hit it exactly.**

Two short-form traps. Integrated loudness over 15–20 seconds is dominated by its loudest five, and
BS.1770 gating behaves oddly on very short programmes containing silence — so measure integrated
**and** short-term (3s) maximum; −14 integrated peaking at −8 short-term over the impact feels shouty
and still gets pulled down. And **the opening impact is the most common clipping site in the piece** —
check true peak over the first 500 ms, after encode, not before.

## Music Licensing — The Clause That Ends Projects

It has one name: **paid advertising** (also "paid media", "advertising and promotion").

Catalogues draw the line between a **creator tier** — content on *your own channels*, including
sponsored and branded content there — and a **commercial tier** covering advertising, client work and
brand campaigns. A stinger sitting organically on your own channel and landing page is often covered
by the cheaper tier. **The moment a dollar of media spend goes behind it, most creator tiers stop
covering it** — and the track you already shipped in three aspect ratios becomes an infringement.

As of 2026 and subject to restructuring: Epidemic Sound's Creator plan covers sponsored and branded
content on your own channels but *not* digital advertising for a brand, which needs their Commercial
plan; Artlist's unified licence permits monetization and sponsorship from its Personal tier, with
higher tiers existing because larger uses carry caps. **Verify both against the vendor's current
licence text — both restructure roughly annually.**

Three axes actually determine coverage, and licence pages usually foreground only one:

1. **Media type** — organic social / paid social / display / TV / OOH / cinema are separate grants.
2. **Term, territory and spend ceiling** — many "commercial" licences quietly cap at 12 months, one
   country, or a spend threshold above which you must upgrade.
3. **Whether the grant survives cancellation** — this decides whether cancelling the subscription
   un-clears your launch spot.

**AI music.** Suno requires a paid tier for *any* commercial use; free-tier output is personal
non-commercial listening, which excludes advertising outright. The deeper issue survives paying: it
**assigns you whatever rights exist and warrants nothing.** Combined with the US Copyright Office's
position on non-human authorship, a purely generated track may be uncopyrightable — you can use it,
and you cannot stop a competitor generating a near-identical one and running it against you. There are
also live label suits whose outcome can change terms on tracks already in market. So: **screenshot the
terms page at generation time**, store the prompt, model version and track ID with the project, and
prefer generated music for texture and beds rather than for the hook that becomes the brand's sonic
identity.

**Before shipping, not after** — a `licenses/` folder holding, for *every* music cue, SFX, whoosh
pack, font, stock shot and any UI sound sampled from the product:

- a licence certificate naming the **licensee entity** (not a person's account email), the asset ID and the date;
- explicit **paid-media coverage** if any spend is planned, or a written note that the piece is organic-only plus a trigger to re-clear before any boost;
- for AI assets: the terms screenshot, plan tier at generation time, prompt and asset ID;
- the vendor's **Content ID / rights-management clearance**, obtained *before* launch day. A properly licensed track still trips Content ID, and discovering the clearance form exists while the launch video is muted is a bad hour.

**If you cannot produce that file for an asset, the asset is not cleared**, whatever anyone remembers.
Never source from a "no copyright music" upload, a royalty-free compilation channel, or a YouTube
Audio Library track without reading *that track's* current, per-track attribution requirement.

## Claims, Disclosures And Store Traps

**Superlatives.** "Best", "#1", "fastest" are objective claims if a reasonable viewer reads them as
factual, and a factual superlative needs a **named, dated, methodologically-disclosed source on
screen** — not in the description, not on the landing page. Puffery is defensible; a measurable
superlative is not. The cheapest fix is nearly always deleting it, which also makes the spot better.

**Comparative claims naming a competitor.** In the US, Lanham Act §43(a)(1)(B) reaches false *or
misleading* statements of fact in commercial advertising — and **literally true statements still
create liability if presented misleadingly.** In the EU, Directive 2006/114/EC permits comparison only
where it is not misleading, compares goods meeting the same needs, compares **verifiable and material**
features, and neither denigrates the rival nor takes unfair advantage of their mark. Operationally: a
written substantiation file — test method, date, exact versions compared, who ran it — completed
**before** the spot ships, and the on-screen wording matches it **phrase for phrase**, not approximately.

**Pricing on screen goes stale, and stale pricing is a false statement.** A price burned into a spot
that lives on the landing page in three ratios and inside a store preview needing a review cycle to
replace becomes wrong the day pricing changes — and it will. **Default: do not show prices.** If one
must appear, use "from $X" with an on-screen "as of <month year>", and record it so a pricing change is
a hard re-cut trigger. Same for free-trial lengths, plan names, seat counts, "over N users" counters,
funding mentions and supported OS versions.

**Testimonials.** FTC Endorsement Guides, 16 CFR Part 255, revised 29 June 2023: "clear and
conspicuous" means **difficult to miss and easily understandable**, and a disclosure for a visual
representation must itself appear visually. In a muted vertical that means **burned in, readable, held
long enough to read** — never a caption line, never the description, never a six-frame flash. Disclose
material connections. Actors portraying users must be identified as such. Atypical results require the
**typical** result stated, not "results may vary" mouse type.

**Meta ad policy** evaluates ad copy, creative, **landing page and comments together** — a
policy-clean spot pointing at a non-compliant page still gets rejected.

**App Store.** Guideline 2.3 requires metadata to reflect the app's core experience and stay current.
**App Previews must use footage captured on device — your cinematic stinger is not an App Store
preview.** They are two deliverables; a spot full of designed B-roll and composited UI will be
rejected, so plan the device-captured 15–30s variant from the same script or accept that the store slot
gets its own cut. 2.3.9: you must own rights to everything shown, and account data must be **fictional**.
2.3.10: **no names, icons or imagery of other mobile platforms** — the "available on iOS and Android"
end card that is correct on your website gets the preview rejected, so build a store-variant end frame.
Specs: 15–30s, up to 3 per localization, ≤500 MB, H.264 High 4.0 at 10–12 Mbps or ProRes 422 HQ, AAC
256 kbps stereo, default poster frame at 5s.

**Google Play** wants a **30–120 second** full YouTube URL, public or unlisted, not age-restricted,
**monetization off** so ads do not play before your own promo, with a feature graphic present for it
to display at all. **A 20-second stinger is disqualified by length** — decide this at the beat-map
stage, not at upload.

**Accessibility, now also a legal surface** (European Accessibility Act obligations from June 2025):
captions burned in, text contrast ≥4.5:1 against the worst frame it covers, and **no more than three
flashes per second** (WCAG 2.3.1). A bold, VJ-inflected stinger will fail the flash rule by accident.
Check it deliberately.

**Two absolutes:** every identifiable person on screen has a signed release, and every screen shows
fabricated data — no real customer, no real card, no real domain, not blurred, not for four frames.

## What `check` Cannot See

**A stinger does not go stale when a file changes.** Its `watch` list is nearly file-blind, and that is
its defining property: it goes stale on **positioning** — the product name, the price, the tagline, the
one-line pitch, the hero screen, the platforms claimed, store availability. Point `watch` at marketing
copy, pricing config, store listings and the landing page, not at implementation.

So **the parent's `check` will usually report the stinger clean while it is materially wrong.** Its
real staleness review is a human question asked on every run: *is this still what the product is?*
The trigger is a marketing event, not a diff. Register it with exactly those triggers and stop.

## The Ship Gate

Thirteen checks, run on the **delivered files**, not the timeline. Any failure is a re-cut.

1. **Mute test.** Silent, on a phone, at arm's length. Can a stranger say what the product is and who it is for?
2. **Two-second test.** Freeze at 0:02 — is the idea legible? Export the first frame at 200px wide; does it still read? Is it a logo or black?
3. **Last-frame test.** Pause on the final frame: name, one line, one destination, completely static.
4. **Crop test.** Overlay the 9:16 and 1:1 masks across every frame. Nothing load-bearing outside the protected column.
5. **Chrome test.** Post to a private slot and screenshot on a **real device** with the platform's real UI on top. Templates lie; rails move between app versions.
6. **Loudness.** Delivered file: −14 ±0.5 LUFS integrated, short-term max within ~4 LU of integrated, true peak ≤ −1.0 dBTP including the first 500 ms. Unlisted YouTube upload should read near **0.0 dB** content loudness.
7. **Dwell test.** Every card read aloud at natural speed while on screen.
8. **Claim file.** Every on-screen factual statement has a line in the substantiation doc with source and date, and the wording matches.
9. **Licence file.** A certificate for every asset, covering paid media if any spend is planned.
10. **`never_say` pass** — applied to spoken copy, on-screen text, **and anything legible inside captured UI.** Screen copy is copy.
11. **Stale-data pass** — prices, plan names, counters, dates, OS versions, any UI redesigned since capture.
12. **Store-variant pass** — device-captured and badge-free for App Store; ≥30s and monetization-off for Play.
13. **The one-idea test.** Someone who did not make it watches once, unpaused, then says the idea back. Two things or nothing means re-cut. This is the only check that catches a technically flawless spot that says nothing.

And the inherited law: **never bless a build you did not watch, end to end, with sound.** Then watch it
again with sound off, because that is how most of its real plays happen.

## What This Skill Must Not Do

- Plan a catalog, or accept "can we get a few more like this" — that is a campaign, and it is `/auto-media-maker`'s scope. Saying so is the correct answer.
- Treat cutdowns as new pieces. They are renders of the same master.
- Re-ask the pipeline, avatar, voice, brand or `never_say` interview.
- Stand up a second config, memory file, task list or CLI.
- Put a talking avatar in a 20-second launch spot.

## Rationalization Table

| Excuse | Reality |
|---|---|
| "Open on the logo, it's brand" | The logo is information they cannot use yet. It costs the only two seconds you are guaranteed |
| "Three features in twenty seconds" | They will remember zero. One shown properly beats three mentioned |
| "The music carries it" | Much of the audience never hears it. If the idea needs the track, the idea is not on screen |
| "Auto-captions will handle it" | Platform-positioned, restyled, and absent on your own site. Burn your own |
| "Make it louder, it'll cut through" | Normalization only turns things down. A hot master arrives quieter-sounding and crushed |
| "It's an ad, one superlative is fine" | The banned list has no advertising exemption. A measurable superlative needs a dated source on screen |
| "It's just background music" | Paid media is a separate grant almost everywhere. Check the tier before the spend |
| "The AI track is ours, we paid" | You were assigned whatever rights exist, warranted as nothing. Screenshot the terms, keep the ID |
| "We'll fix the price in the description" | The false statement is the one burned into the frame, in three ratios and a store slot |
| "Use the stinger as the App Store preview" | Previews must be device-captured, 15–30s, with no other-platform badges |
| "It's 20 seconds, put it on Play too" | Play requires 30–120s. Decide at the beat map, not at upload |
| "Nothing in the code changed, the stinger's fine" | It goes stale on price, name and positioning. `check` cannot see any of those |
| "The CTA looks great at the bottom" | In vertical the bottom ~400px is platform chrome. Nobody will ever see it |
| "Cut it faster, it feels slow" | Slow is confident. What felt slow was a card nobody had time to read |

## Red Flags — Stop

- Shipping with any asset that has no licence certificate naming the licensee — or with a creator-tier track behind paid media
- An on-screen superlative, comparison, price or count with no dated line in the substantiation file
- Delivering the stinger as an App Store preview without a device-captured, badge-free variant
- A final frame that is still moving, or a first frame that is a logo or black
- Blessing without watching it muted, on a phone, with the platform's real chrome on top

---
name: auto-device-lock
description: "Use at the start of every session, and before any command that touches physical hardware — adb, fastboot, scrcpy, screenshots, screen recording, esptool/idf.py/platformio, a serial console, xcrun devicectl — on a machine where more than one editor window or agent session may be running; when phones, dev boards or test devices are shared between projects; when a device behaves as though something else is driving it; when a lock looks stale after a crash; or when the user says \"/auto-device-lock\", mentions device conflicts, contention, or which phone a session should use."
---

# /auto-device-lock

Claim a physical device before you touch it, hold it for as long as you need it, and give it back —
so that five windows working on five apps can share three phones without corrupting each other's
tests, and so the ESP32 that one project is flashing is not opened by another project mid-write.

**The standing law: no device operation without a lease you have verified in this same command.**
Not "I claimed it earlier in this session" — earlier is not now. The gap between those two is where
another session's flash lands in your board.

Everything here is built on one fact about how agent sessions run: **every Bash call is a fresh
`bash -c` that exits within milliseconds, while the session itself lives for hours.** A lock held by
the shell dies instantly; an environment variable exported in one call is gone by the next. So the
lease is bound to the session's own long-lived process, and the shell bindings are re-established on
every call that uses them.

The helper is `devlock`, shipped in this skill's directory. If it is missing — a user may have
installed only `SKILL.md` — say so and fall back to Step 8 rather than inventing a lock format.

It is not on `PATH` by default. Resolve it once at the top of the session and reuse that path, or
offer the user the one-time symlink:

```bash
DEVLOCK="$(ls -d ~/.claude/skills/auto-device-lock/devlock \
              ~/.agents/skills/auto-device-lock/devlock 2>/dev/null | head -1)"
ln -sfn "$DEVLOCK" ~/.local/bin/devlock     # optional, once, if ~/.local/bin is on PATH
```

The examples below say `devlock`; use `"$DEVLOCK"` if you did not make the link.

**Subagents never claim and never release.** This rule is load-bearing, so it comes before the
mechanism. Every in-process subagent runs under the *same* `claude` process as its parent, so the
lease's owner triple is identical for all of them — it proves the session is alive, and it cannot tell
two subagents apart. The practical consequence: one subagent's `release --all` frees a device another
subagent is mid-flash on, and the registry will agree that was legitimate. The foreground session
claims and hands each subagent the serial to use; a subagent that believes it needs a device it was
not given should say so and stop, not claim one.

A nested `claude -p` spawned from a Bash call is the opposite case — it is its own process, so the
ancestry walk stops at the *inner* `claude` and it becomes a separate holder that contends with its
own parent. Pass the device down and let it use `-s`.

## Step 0 — Every Session, Before Anything Else

Run this first, every session, without being asked:

```bash
devlock status          # who holds what; reaps leases whose sessions died
devlock devices         # what is attached, and its canonical id
```

`status` prunes dead holders as a side effect, so a crashed session's phone is available again by the
time you have read the output. There is no cleanup command to remember and no daemon to be running.

If this window used a device before, take it back:

```bash
devlock affinity        # what this window/repo used last
```

**Affinity is not a nicety.** A test suite whose screenshots come from a 6.1" phone on Monday and a
tablet on Tuesday produces diffs that are all noise, and a recording that intercuts two devices looks
like a bug report about the product. Same window, same repo, same device — unless someone else has it.

## Step 1 — Claim Before You Touch

```bash
devlock claim <id> [<id>...] --why "what you are doing"   # all or nothing
devlock claim <id> --wait 300 --why "..."                 # queue behind the holder
```

Name the devices by canonical id (`devlock devices` prints them). A serial, a `/dev/tty*`, a
`by-id` name or a model also resolve, and an ambiguous one is rejected rather than guessed.

**`--why` is required in practice even though the flag is optional.** It is the entire content of the
message another session sees when it collides with you, and "held by pid 41232" with no reason is what
makes a person kill a lock they should have waited for.

**A multi-device claim is all-or-nothing.** Ask for three phones and you either get all three or you
get none and nothing is left held. This is not politeness; it is what stops the deadlock where you
hold phone A waiting for phone B while another session holds B waiting for A. Devices are acquired in
canonical-id order, which is the same order in every session, so a cycle cannot form.

Claiming a device you already hold is not an error and does not change your epoch. Run it twice; run
it in a subagent. That is deliberate — you *will* run it twice.

## Step 2 — Bind The Shell, Every Single Call

An `export` does not survive to your next Bash call. So every call that touches a device begins by
re-establishing the binding:

```bash
eval "$(devlock env)" || exit 1
adb -s "$ANDROID_SERIAL" shell screencap -p /sdcard/shot.png
```

`devlock env` exits nonzero and exports nothing if the lease is gone, so that `|| exit 1` is a fence
check as well as a convenience. It is the cheapest correct habit in this skill.

**Never run bare `adb`.** With several devices attached it fails loudly, which is fine. With exactly
one attached it silently succeeds against whatever happens to be plugged in — so the command works
today, and on the day a colleague plugs in a second phone it starts flashing the wrong one. `-s` is
not optional, and `ANDROID_SERIAL` must come from `devlock env`, never from memory.

Holding several Android devices at once is supported and expected; in that case `devlock env` refuses
to pick one for you and prints the per-device lines instead. Pass `-s` explicitly.

## Step 3 — Verify Before Each Batch Of Work

```bash
devlock check <id> && adb -s "$ANDROID_SERIAL" shell ...   # the gate: one line, one code
devlock verify                                    # everything you hold, one line each
# strict form: devlock env exports one variable per held device, named after
# its canonical id with every non-alphanumeric character replaced by _
eval "$(devlock env)"
devlock verify usb:22d9:EILF85KNDIXKGEDM --epoch "$DEVLOCK_EPOCH_usb_22d9_EILF85KNDIXKGEDM"
```

Use `check` as a shell condition rather than something you read and interpret. It prints one line and
returns one code, and every non-OK line ends with the exact command that fixes it:

| Code | | Meaning |
|---|---|---|
| 0 | `OK` | you hold it, at your epoch, attached and healthy |
| 1 | `HELD` | someone else holds it |
| 2 | `FREE` | nobody holds it, including you |
| 4 | `POLICY` | refused: the device is on `never_automate` |
| 5 | `ABSENT` | leased to you but not attached |
| 6 | `FENCED` | your lease lapsed and was re-granted — your state is stale |
| 7 | `UNHEALTHY` | attached but not in a state that accepts commands |

`check` reaps as it runs, so a lease whose session died never blocks you, and a device you lost tells
you *why* you lost it — crashed, frozen, or deliberately taken.

Bare `devlock verify` is the one command that answers "am I allowed to touch what I am about to
touch". It exits nonzero if any answer is anything but `OK`, so it chains: `devlock verify && ...`.

Every grant carries a monotonically increasing **epoch**. If your session was declared dead — frozen,
suspended, its host asleep, its process stopped — and the device was re-granted to someone else, the
epoch in the registry has moved past yours. `verify` fails, and that failure is the only thing standing
between a resumed session and a write into hardware that now belongs to another test.

This is the hole every naive lock has: liveness is checked once at claim time, and the holder is
assumed live forever after. Check the epoch, not your memory.

| `verify` says | What it means |
|---|---|
| `OK` | you hold it, at your epoch, and it is attached and healthy |
| `NOT HELD` | no lease at all — you never claimed it, or you released it |
| `STOLEN` | someone else holds it now. Stop. Do not touch it |
| `FENCED` | your lease lapsed and was re-granted. Your state is stale; re-claim and re-check |
| `ABSENT` | leased to you but unplugged right now |
| `UNHEALTHY` | attached but `unauthorized` / `offline` / `recovery`, not `device` |

## Step 4 — Release, Including When It Goes Wrong

```bash
devlock release <id>     # or: devlock release --all
```

Release when the work is done, not when the turn ends — but a crash needs no cleanup at all. A lease
is valid only while the process that took it is alive, proven by boot id, PID **and** process start
time. Kill the session and the lease evaporates on the next `status`, `claim` or `devices` from anyone.
There is no TTL to tune, no heartbeat to miss, and no stale lock file to delete by hand.

Do not release a device a background job is still using. The foreground task finishing is not the same
event as the device going idle.

## Step 5 — When The Device You Want Is Taken

In order:

1. **Use a different one.** `devlock devices` shows what is free. Note in your report that the
   screenshots came from a different device than usual.
2. **Wait.** `--wait <seconds>` queues with jittered backoff, and reports who is ahead of you.
3. **Ask the human.** Show them the holder, the repo and the reason.
4. **Steal — only with a human's explicit yes:**

```bash
devlock steal <id> --reason "..." --confirm
```

`--confirm` exists so that stealing cannot happen by reflex. A steal breaks a live session's test
mid-run; the victim finds out on its next `verify`, which is exactly why Step 3 is not optional.

**Never work around a lock you could not get.** Unplugging the device, restarting the adb server, or
telling yourself the other session looks idle are all the same mistake with different steps.
`adb kill-server` in particular drops every session's device at once, and the other sessions find out
by their command failing halfway through.

## Step 6 — Identity Is The Part That Silently Goes Wrong

A lock keyed on an unstable name is worse than no lock, because it reports success while protecting
nothing. `devlock` keys on `usb:<vendor>:<serial>` derived from sysfs, and that choice is load-bearing:

- **`transport_id` is never identity.** It is reassigned on every replug and every `adb reboot`.
- **One physical device can appear in two namespaces at once.** A phone exposing a CDC interface is
  both an adb serial and a `/dev/ttyACM*`. Lock it as a tty in one session and as an adb serial in
  another, and both sessions believe they have exclusive access to the same hardware. The canonical id
  collapses those into one lease covering the hardware, not the cable.
- **`/dev/serial/by-id` is not unique.** Two identical CH340 or CP2102 adapters commonly report the
  same serial, and some boards have no `by-id` entry at all. Where the canonical id cannot be formed,
  `devlock` falls back to `ID_PATH` — a physical port, so moving the cable moves the identity, which is
  the honest trade.
- **`by-path` lists the same tty twice** (`usb-` and `usbv2-`). Deduplicate by resolved device.
- **A board that reboots into a different USB personality after flashing** — a CDC firmware replacing
  a UART bridge — comes back with a different id. Re-enumerate rather than trusting the pre-flash name.
- **Network adb, emulators and iOS live in their own namespaces** (`net:`, `emu:`, `ios:`) because
  their identity has different failure modes. `adb tcpip` changes a device's serial mid-session:
  re-claim afterwards rather than assuming the lease followed it.

- **Placeholder and short serials are common.** A literal `0123456789ABCDEF`, or a six-digit counter,
  is not unique to a unit. `devlock devices` flags these; when you see that warning, plug in a second
  unit of the same model and confirm the ids differ before trusting the lock on either.
- **`ttyACM0` is a recycled minor number, not a name.** The same board can be `ttyACM0` today and
  `ttyACM1` after a reboot while its canonical id holds. Never key anything on the number.
- **An empty `adb devices` does not mean the phones are gone.** It usually means another adb server
  owns them. Do not conclude a device is absent from an empty list, and do not "fix" it by killing
  the server.

Check state, not just presence. `unauthorized`, `offline`, `recovery` and `sideload` accept some
commands and silently drop others; `devlock claim` refuses them unless you pass `--allow-unhealthy`.
`adb root`, `adb reboot bootloader`, recovery and sideload each move the device into a *different*
namespace — `fastboot devices` is not `adb devices` — so re-claim after the hop rather than assuming
the lease followed it.

## Environment

| Variable | |
|---|---|
| `DEVLOCK_DIR` | Where the lease registry lives. Default `$XDG_RUNTIME_DIR/auto-device-lock`. Point it somewhere scratch to test without touching real leases |
| `DEVLOCK_POLICY` | Path to the policy file, overriding `~/.local/state/auto-device-lock/policy.json` |
| `DEVLOCK_SESSION_PID` | The process whose life the lease is bound to. Only for a detached child that has no agent ancestor to find |
| `ANDROID_SERIAL`, `DEVLOCK_PORT`, `DEVLOCK_EPOCH_*` | Written by `devlock env`, read by you. Never set them by hand — `ANDROID_SERIAL` set by hand routes around the lock entirely |

`devlock devices` runs `adb devices`, which **starts an adb server if none is running.** That is
normally what you want, but it is a side effect: on a machine where the policy is one server, run it
after the server is up rather than letting an arbitrary session start it.

## Step 7 — Devices That Must Never Be Automated

Some hardware is off limits — a tablet that is someone's daily driver, a board wired into a rig, a
phone with a customer's data on it. Record that once, in `~/.local/state/auto-device-lock/policy.json`:

```json
{ "never_automate": ["usb:04e8:R52Y5057J4Y"],
  "aliases": { "test-phone": "usb:22d9:EILF85KNDIXKGEDM" } }
```

`claim` refuses a forbidden device outright. This is the right place for a rule the user has already
told you once — a preference that lives only in a conversation is a preference that gets violated in
the next session.

## Step 8 — Always-On, And What To Do Without The Helper

The skill fires on its description, which covers the common cases. To make it genuinely unconditional,
offer to install the two hooks — and **ask before editing the user's settings**:

```jsonc
// ~/.claude/settings.json
"SessionStart": [ { "hooks": [ { "type": "command", "timeout": 10,
    "command": "~/.claude/skills/auto-device-lock/devlock-hook session-start   # auto-device-lock" } ] } ],
"PreToolUse":   [ { "matcher": "Bash", "hooks": [ { "type": "command", "timeout": 10,
    "command": "~/.claude/skills/auto-device-lock/devlock-hook pre-bash   # auto-device-lock" } ] } ]
```

The first prints the device situation into every session's context. The second **denies** a Bash call
that reaches hardware this session has not leased, with a message naming the command to fix it. That
is what turns a convention into something an agent cannot absent-mindedly skip. Both fail open: any
internal error allows the command through, because a guard that blocks work when it breaks is a guard
the user disables within the hour.

**Set the `timeout` and keep the `# auto-device-lock` marker.** Hook timeout defaults are not uniform
across events and can be far longer than you would guess — a hook with none set was measured being
waited on for two full minutes. The marker is how you find these entries again to remove them, since
this skill ships no installer.

Note the entry point is `devlock-hook`, not `devlock`. It is a shell prefilter that matches the
command against the device tools with a `case` and only starts Python when one hits — 3 ms on an
ordinary command instead of 55 ms. A guard that taxes every `git status` gets turned off, and a guard
that is off protects nothing.

**A lock only binds the sessions that run it.** If another window is on an older copy of this skill,
or has no lock at all, it will take your device without ever seeing your lease. When that is possible,
say so in your report rather than implying the hardware was protected — and get the skill installed
everywhere before relying on it. Two schemes that cannot see each other are worse than one everybody
runs, because both report success.

Two environment variables route around the lock entirely: `ANDROID_SERIAL` selects a device without
`-s`, and `ANDROID_ADB_SERVER_PORT` points at a *different adb server* whose devices this registry
knows nothing about. Only ever set `ANDROID_SERIAL` from `devlock env`, and never set the port.

On a stock macOS, `python3` may be a Command Line Tools stub that pops a GUI installer when invoked.
Check `python3 -V` returns a version before relying on the helper in an unattended run.

If `devlock` is not installed at all, do not improvise a lock file format — a second, incompatible
scheme is worse than none. Announce the constraint, ask the user which device this window owns, use
`-s` with that serial exclusively, and say in your report that arbitration was manual.

## Working With The Other Skills

`/auto-balance` decides **how much** of the machine this session may use — cores, memory, how many
agents. This skill decides **which hardware** it may touch. When both apply, balance sizes the session
and this one claims the devices; neither overrides the other.

## Rationalization Table

| Excuse | Reality |
|---|---|
| "Only one device is plugged in, `adb shell` is unambiguous" | Today. The day a second appears, that command silently drives the wrong phone |
| "I claimed it at the start of the session" | Earlier is not now. `verify` with your epoch, or you are guessing |
| "I exported ANDROID_SERIAL already" | Every Bash call is a new process. It is gone. `eval "$(devlock env)"` |
| "The lock file is stale, I'll delete it" | There are no stale locks. If it is still listed, its session is alive |
| "The holder crashed, so I must clean up" | A dead holder's lease is already invalid. Run `devlock status` and take it |
| "The other session looks idle" | Idle is not finished. It may be waiting on a build or a human |
| "I'll restart the adb server to clear this up" | That drops every session's device mid-command |
| "I only need it for one screenshot" | One screenshot during another session's install is what corrupts the install |
| "I'll unplug it and plug it back in" | Same as stealing, minus the record of who did it |
| "Two sessions reading logcat can't conflict" | They can and do — and one of them is about to do more than read |
| "by-id is a stable name" | Not for two identical adapters sharing a serial. That is the common case, not the rare one |
| "I locked the tty, so adb is a different device" | It is the same physical unit. That is what the canonical id is for |
| "My subagent released it, so I'm done" | Subagents do not claim or release. They share your PID; the registry cannot tell them apart |
| "`adb devices` is empty, the phone is unplugged" | Another adb server owns it. An empty list is not an absence |
| "The lock said free, so nobody is using it" | Only sessions running this skill appear. A window without it is invisible |
| "I'll claim all four in case I need them" | Four windows are waiting. Claim what you use, release what you finish |
| "The board is only being read, not written" | Opening the port resets most boards. There is no read-only open |

## Red Flags — Stop

- Any `adb`, `fastboot`, `esptool`, `idf.py`, `scrcpy` or serial-console command with no lease held
- Bare `adb` with no `-s`, or an `ANDROID_SERIAL` you did not get from `devlock env` this call
- A device operation after a `verify` that returned anything but `OK`
- Deleting, editing or hand-writing anything in the lock directory
- `adb kill-server`, unplugging, or power-cycling a device to get around a lock
- Stealing without `--reason` and a human's explicit yes
- Claiming a device listed in `never_automate`
- Probing a serial port by opening it to see whether it is free — that resets the board; use the
  registry, or `fuser` / `lsof`
- Releasing while a background job of yours is still driving the device
- A subagent running `devlock claim` or `devlock release` instead of using the serial it was handed
- Setting `ANDROID_SERIAL` by hand, or setting `ANDROID_ADB_SERVER_PORT` at all
- Concluding a device is gone because `adb devices` came back empty
- Trusting a lock on a device whose serial `devlock devices` flagged as weak, without checking
- Finishing a session still holding devices you stopped using an hour ago
- Reporting screenshots or recordings without saying which device produced them

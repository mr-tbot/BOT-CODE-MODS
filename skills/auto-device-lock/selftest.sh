#!/usr/bin/env bash
# devlock self-check. Uses a scratch registry and fake holder processes; touches
# no real device beyond read-only enumeration. Run it after editing devlock.
#   bash selftest.sh
set -u
# Exit codes asserted below come from devlock's one table:
#   0 OK  1 HELD-by-someone-else  2 FREE  4 POLICY  5 ABSENT  6 FENCED  7 UNHEALTHY
DL="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/devlock"
SCRATCH="$(mktemp -d)"
export DEVLOCK_DIR="$SCRATCH/reg"
mkdir -p "$DEVLOCK_DIR"
export DEVLOCK_POLICY=/nonexistent
trap 'rm -rf "$SCRATCH" "$DEVLOCK_DIR"; for p in ${HOLDERS:-}; do kill -9 "$p" 2>/dev/null; done' EXIT

pass=0; fail=0
ok()   { pass=$((pass+1)); printf '  ok   %s\n' "$1"; }
bad()  { fail=$((fail+1)); printf '  FAIL %s\n' "$1"; }
is()   { if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (got '$2', want '$3')"; fi; }

HOLDERS=""
spawn() { setsid bash -c 'exec sleep 300' >/dev/null 2>&1 </dev/null & local p=$!; HOLDERS="$HOLDERS $p"; echo "$p"; }

DEV="$($DL devices --json | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d[0]["id"] if d else "")')"
DEV2="$($DL devices --json | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d[1]["id"] if len(d)>1 else "")')"
if [ -z "$DEV" ]; then
  echo "no devices attached — running only the checks that do not need one"
fi

echo "identity"
is "comm-safe starttime parse" \
   "$(python3 - <<'PY'
import ctypes, os, time
libc = ctypes.CDLL("libc.so.6")
pid = os.fork()
if pid == 0:
    libc.prctl(15, b"ev il) ) x\0", 0, 0, 0); time.sleep(3); os._exit(0)
time.sleep(0.3)
raw = open(f"/proc/{pid}/stat").read()
safe = raw.rsplit(") ", 1)[1].split()[19]
naive = raw.split()[21]
os.kill(pid, 9)
print("differ" if safe != naive else "same")
PY
)" "differ"

echo "leases"
if [ -n "$DEV" ]; then
  A=$(spawn); B=$(spawn)
  DEVLOCK_SESSION_PID=$A $DL claim "$DEV" --why selftest >/dev/null 2>&1
  is "claim succeeds" "$?" "0"
  DEVLOCK_SESSION_PID=$B $DL claim "$DEV" --why contend >/dev/null 2>&1
  is "second session is refused (RC_HELD)" "$?" "1"
  DEVLOCK_SESSION_PID=$A $DL claim "$DEV" --why again >/dev/null 2>&1
  is "re-claim by the holder is not an error" "$?" "0"
  ep=$(DEVLOCK_SESSION_PID=$A $DL status --json | python3 -c 'import json,sys;print(list(json.load(sys.stdin)["leases"].values())[0]["epoch"])')
  DEVLOCK_SESSION_PID=$B $DL release "$DEV" >/dev/null 2>&1
  is "release refuses another session's lease (RC_HELD)" "$?" "1"

  kill -9 $A; sleep 0.3
  DEVLOCK_SESSION_PID=$B $DL claim "$DEV" --why "after crash" >/dev/null 2>&1
  is "a killed holder's lease is reclaimable with no reaper" "$?" "0"
  DEVLOCK_SESSION_PID=$A $DL verify "$DEV" --epoch "$ep" >/dev/null 2>&1
  is "the dead session is fenced out at its old epoch (RC_FENCED)" "$?" "6"
  DEVLOCK_SESSION_PID=$B $DL verify "$DEV" >/dev/null 2>&1
  is "the new holder verifies clean" "$?" "0"

  DEVLOCK_SESSION_PID=$B $DL steal "$DEV" --reason x >/dev/null 2>&1
  is "stealing from yourself is refused" "$?" "1"
  DEVLOCK_SESSION_PID=$B $DL env >/dev/null 2>&1
  is "env exports bindings while a lease is held" "$?" "0"
  DEVLOCK_SESSION_PID=$B $DL release --all >/dev/null 2>&1
  is "release --all works" "$?" "0"
  DEVLOCK_SESSION_PID=$B $DL env >/dev/null 2>&1
  is "env fails closed once the lease is gone" "$?" "1"
fi

if [ -n "$DEV2" ]; then
  C=$(spawn); D=$(spawn)
  DEVLOCK_SESSION_PID=$C $DL claim "$DEV" --why one >/dev/null 2>&1
  DEVLOCK_SESSION_PID=$D $DL claim "$DEV" "$DEV2" --why both >/dev/null 2>&1
  is "a partly-blocked multi-claim grants nothing (RC_HELD)" "$?" "1"
  n=$($DL status --json | python3 -c 'import json,sys;print(len(json.load(sys.stdin)["leases"]))')
  is "  and leaves exactly the one pre-existing lease" "$n" "1"
  DEVLOCK_SESSION_PID=$C $DL release --all >/dev/null 2>&1
fi

echo "races"
if [ -n "$DEV" ]; then
  ps=""; for i in $(seq 1 16); do p=$(spawn); ps="$ps $p"; done
  won=0
  for p in $ps; do
    DEVLOCK_SESSION_PID=$p $DL claim "$DEV" --why race >/dev/null 2>&1 && won=$((won+1))
  done
  is "16 concurrent claimants produce exactly one winner" "$won" "1"
  $DL release --all >/dev/null 2>&1
  for p in $ps; do kill -9 "$p" 2>/dev/null; done
  sleep 0.2; $DL reap >/dev/null 2>&1
fi

echo "exit codes"
if [ -n "$DEV" ]; then
  E=$(spawn)
  $DL check "$DEV" >/dev/null 2>&1; is "check on a free device returns RC_FREE" "$?" "2"
  DEVLOCK_SESSION_PID=$E $DL claim "$DEV" --why codes >/dev/null 2>&1
  DEVLOCK_SESSION_PID=$E $DL check "$DEV" >/dev/null 2>&1; is "check on a held device returns RC_OK" "$?" "0"
  DEVLOCK_SESSION_PID=$E $DL check "$DEV" --epoch 999999 >/dev/null 2>&1
  is "check at a stale epoch returns RC_FENCED" "$?" "6"
  F=$(spawn)
  DEVLOCK_SESSION_PID=$F $DL check "$DEV" >/dev/null 2>&1
  is "check on someone else's device returns RC_HELD" "$?" "1"
  kill -9 $E; sleep 0.3
  DEVLOCK_SESSION_PID=$F $DL check "$DEV" >/dev/null 2>&1
  is "a dead holder's device reads FREE again" "$?" "2"
  ep=$($DL status --json | python3 -c 'import json,sys;print(len(json.load(sys.stdin)["leases"]))')
  is "  and its lease is gone" "$ep" "0"
  DEVLOCK_SESSION_PID=$F $DL verify "$DEV" >/dev/null 2>&1
  is "the evicted session is told, not silently allowed" "$?" "6"
fi

echo "guard: command position"
guard() {
  printf '%s' "$(python3 -c 'import json,sys;print(json.dumps({"tool_name":"Bash","tool_input":{"command":sys.argv[1]}}))' "$1")" \
    | "$DL" hook pre-bash | python3 -c 'import sys;print("DENY" if sys.stdin.read().strip() else "ALLOW")'
}
# A guard that fires on prose gets switched off, and then it protects nothing.
for c in "grep adb notes.txt" "man adb" "which adb" "rg -n adb ." \
         "command -v adb" "type -p adb" "screen -ls" "screen -r work" \
         "echo accumulate audio documents" \
         "echo see adb docs" "ls /opt/platform-tools/adb" "adb devices" "adb version"; do
  is "allows: $c" "$(guard "$c")" "ALLOW"
done
# Every command-position occurrence is checked, not just the first: a chain that
# opens with a harmless subcommand must not smuggle the next one through.
for c in "adb shell ls" "cd /tmp && adb devices -l && adb shell ls" \
         "sudo esptool.py --port /dev/ttyACM0 flash_id" \
         "for i in 1 2; do adb shell ls; done" "adb kill-server" \
         "nohup adb logcat &" "timeout 5 adb shell ls" \
         "cd /tmp/x#y && adb -s FOO shell ls" \
         "git log --grep=#42 -1 && adb -s FOO install app.apk" \
         "screen /dev/ttyUSB0 115200" "cu -l /dev/ttyUSB0" "pio run -t upload" \
         "command adb shell ls"; do
  is "denies: $c" "$(guard "$c")" "DENY"
done

echo "guard: eval safety"
# devlock env output is documented as something to eval, and a USB device picks
# its own serial in firmware, so an unquoted value here is remote code execution
# triggered by plugging a board in.
evil=$(python3 - <<'PYX'
import io, contextlib, os
m = {}
exec(compile(open(os.environ["AA_PATH"]).read().replace('if __name__ == "__main__":', "if False:"),
             "devlock", "exec"), m)
buf = io.StringIO()
with contextlib.redirect_stdout(buf):
    m["_print_env"]([{"id": "usb:d:e", "kind": "android",
                      "adb_serial": "X; touch /tmp/aw-rce-canary #", "_epoch": 1}])
print(buf.getvalue().strip())
PYX
)
rm -f /tmp/aw-rce-canary
eval "$evil" 2>/dev/null
[ -e /tmp/aw-rce-canary ] && bad "a hostile device serial cannot execute through eval" \
  || ok "a hostile device serial cannot execute through eval"
rm -f /tmp/aw-rce-canary

echo "guard: prefilter"
HOOK="$(dirname "$DL")/devlock-hook"
if [ -x "$HOOK" ]; then
  pre() { printf '%s' "$1" | "$HOOK" pre-bash >/dev/null 2>&1; echo "$?"; }
  is "a payload with no command key fails open" "$(pre '{"tool_name":"Bash"}')" "0"
  is "an empty payload fails open"              "$(pre '')" "0"
  is "invalid JSON fails open"                  "$(pre 'not json')" "0"
  is "a command substitution is not evaluated" \
     "$(pre '{"tool_input":{"command":"echo $(touch /tmp/aw-selftest-pwned)"}}'; \
        [ -e /tmp/aw-selftest-pwned ] && echo INJECTED)" "0"
  rm -f /tmp/aw-selftest-pwned
  ok "an ordinary command skips python entirely (fast path)" \
     "$(printf '%s' '{"tool_input":{"command":"git status"}}' | "$HOOK" pre-bash | wc -c)" 
  cp "$HOOK" "$SCRATCH/dh" 2>/dev/null && \
    sed -i 's|DEVLOCK="$DIR/devlock"|DEVLOCK="$DIR/missing"|' "$SCRATCH/dh" && \
    chmod +x "$SCRATCH/dh"
  printf '%s' '{"tool_input":{"command":"adb shell ls"}}' | "$SCRATCH/dh" pre-bash >/dev/null 2>&1
  is "a missing devlock binary fails open" "$?" "0"
  # shlex is quadratic; a 2 MB heredoc took 49 s and blew the hook timeout,
  # failing open on exactly the largest commands.
  python3 -c "
import json,sys;sys.stdout.write(json.dumps({'tool_name':'Bash','tool_input':{'command':'adb -s F shell '+'A'*2000000}}))" > "$SCRATCH/big.json"
  t0=$(date +%s%N); "$HOOK" pre-bash < "$SCRATCH/big.json" >/dev/null 2>&1; t1=$(date +%s%N)
  ms=$(( (t1-t0)/1000000 ))
  [ "$ms" -lt 2000 ] && ok "a 2 MB command is handled in ${ms}ms, not tens of seconds" \
    || bad "a 2 MB command took ${ms}ms"
  # The prefilter must never be weaker than the tool it fronts.
  for c in "adb -s F shell ls" "a''db -s F shell ls" "pio run -t upload" "git status"; do
    j=$(python3 -c 'import json,sys;print(json.dumps({"tool_name":"Bash","tool_input":{"command":sys.argv[1]}}))' "$c")
    a=$(printf '%s' "$j" | "$HOOK" pre-bash | head -c1)
    b=$(printf '%s' "$j" | "$DL" hook pre-bash | head -c1)
    is "prefilter agrees with the guard: $c" "$([ -n "$a" ] && echo D || echo A)" "$([ -n "$b" ] && echo D || echo A)"
  done
fi

echo "robustness"
printf 'not json {{{' > "$DEVLOCK_DIR/registry.json"
$DL status >/dev/null 2>&1
is "a corrupt registry does not crash" "$?" "0"
ls "$DEVLOCK_DIR"/registry.corrupt.* >/dev/null 2>&1
is "  and the wreckage is kept" "$?" "0"
$DL claim definitely-not-a-real-device >/dev/null 2>&1
is "an invented device id is rejected" "$?" "1"
$DL reap >/dev/null 2>&1; is "reap is safe on an empty registry" "$?" "0"

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]

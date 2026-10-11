#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mkdir -p "$stub_bin" "$test_home"

cat >"$stub_bin/kestrel-migrate" <<'SH'
#!/bin/bash
if [[ ${1:-} == "--pending" && ${KESTREL_TEST_PENDING_MIGRATIONS:-0} == 1 ]]; then
  echo 200-migration.sh
  exit 0
else
  exit 1
fi
SH
chmod +x "$stub_bin/kestrel-migrate"

cat >"$stub_bin/kestrel-notification-wait" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$stub_bin/kestrel-notification-wait"

cat >"$stub_bin/kestrel-notification-send" <<'SH'
#!/bin/bash
[[ ${KESTREL_TEST_NOTIFY_SEND:-send} == "fail" ]] && exit 1
printf '%s\n' "$@" >"$KESTREL_TEST_NOTIFY_ARGS"
SH
chmod +x "$stub_bin/kestrel-notification-send"

runtime_dir="$test_tmp/runtime"
mkdir -p "$runtime_dir"

run_notify() {
  HOME="$test_home" \
  PATH="$stub_bin:$ROOT/bin:$PATH" \
  XDG_RUNTIME_DIR="$runtime_dir" \
  KESTREL_TEST_PENDING_MIGRATIONS="$1" \
  KESTREL_TEST_NOTIFY_ARGS="$test_tmp/notify-args" \
  KESTREL_TEST_NOTIFY_SEND="${2:-send}" \
    "$ROOT/bin/kestrel-migrate-notify"
}

notify_args_written() {
  [[ -s $test_tmp/notify-args ]]
}

run_notify 0 >"$test_tmp/not-pending.out" 2>"$test_tmp/not-pending.err"
[[ ! -s $test_tmp/not-pending.out ]] || fail "migration notifier stays quiet on stdout without pending migrations"
[[ ! -s $test_tmp/not-pending.err ]] || fail "migration notifier stays quiet on stderr without pending migrations"
pass "migration notifier ignores users with no pending migrations"

run_notify 1 fail >"$test_tmp/pending.out" 2>"$test_tmp/pending.err"
grep -q 'Kestrel has pending migrations' "$test_tmp/pending.err" || fail "migration notifier explains pending migrations without notification system"
grep -q '200-migration.sh' "$test_tmp/pending.err" || fail "migration notifier lists pending migration names"
pass "migration notifier reports pending migrations"

run_notify 1 >"$test_tmp/notified.out" 2>"$test_tmp/notified.err"
notify_args_written || fail "migration notifier sends a notification for pending migrations"
grep -Fx 'Pending Kestrel Migrations' "$test_tmp/notify-args" >/dev/null || fail "migration notifier uses pending migrations title"
grep -Fx 'Click to run 1 pending migration.' "$test_tmp/notify-args" >/dev/null || fail "migration notifier describes the pending migration"
grep -Fx -- '-g' "$test_tmp/notify-args" >/dev/null || fail "migration notifier includes the large-slot glyph flag"
pass "migration notifier uses the actionable notification format"

# The notifier is a Type=oneshot with no start timeout, so it must not stay
# activating until the toast is answered. Handing the click command to the shell
# is what lets it exit immediately.
rm -f "$test_tmp/notify-args"
run_notify 1 >/dev/null 2>&1
notify_args_written || fail "migration notifier sends the notification before exiting"
grep -Fx -- '--exec' "$test_tmp/notify-args" >/dev/null ||
  fail "migration notifier attaches the click command to the toast"
grep -Fx 'kestrel-launch-floating-terminal-with-presentation' "$test_tmp/notify-args" >/dev/null &&
  grep -Fx 'kestrel-migrate' "$test_tmp/notify-args" >/dev/null ||
  fail "migration notifier points the click command at kestrel-migrate"
pass "migration notifier lets the shell own the click instead of waiting for it"

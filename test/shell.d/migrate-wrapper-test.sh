#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_root="$test_tmp/helios"
test_home="$test_tmp/home"
stub_bin="$test_tmp/bin"
mkdir -p "$test_root/migrations" "$test_home" "$stub_bin"

cat >"$stub_bin/helios-notification-dismiss" <<'SH'
#!/bin/bash
printf '%s\n' "$1" >>"$TEST_DISMISSALS"
SH
chmod +x "$stub_bin/helios-notification-dismiss"

cat >"$test_root/migrations/100-migration.sh" <<'SH'
echo migration >>"$TEST_CALLS"
SH

run_migrate() {
  HOME="$test_home" \
  HELIOS_PATH="$test_root" \
  PATH="$stub_bin:$ROOT/bin:$PATH" \
  TEST_CALLS="$test_tmp/calls" \
  TEST_DISMISSALS="$test_tmp/dismissals" \
    "$ROOT/bin/helios-migrate" "$@"
}

: >"$test_tmp/calls"
run_migrate >"$test_tmp/migrate.out"
[[ $(sed -n '1p' "$test_tmp/calls") == "migration" ]] || fail "helios-migrate runs pending migrations"
pass "helios-migrate runs migrations without force"

grep -Fx 'HeliOS Migrations' "$test_tmp/dismissals" >/dev/null || fail "helios-migrate dismisses migration notifications"
pass "helios-migrate clears completed migration notifications"

rm -rf "$test_home/.local/state/helios/migrations"
run_migrate --pending >"$test_tmp/pending.out"
grep -q '^100-migration\.sh$' "$test_tmp/pending.out" || fail "helios-migrate --pending lists pending migrations"
pass "helios-migrate --pending lists pending migrations"

run_migrate >"$test_tmp/migrate-second.out"
if run_migrate --pending >"$test_tmp/not-pending.out"; then
  fail "helios-migrate --pending exits non-zero without pending migrations"
fi
[[ ! -s $test_tmp/not-pending.out ]] || fail "helios-migrate --pending stays quiet without pending migrations"
pass "helios-migrate --pending reports no pending migrations"

if run_migrate --force >"$test_tmp/force.out" 2>&1; then
  fail "helios-migrate rejects obsolete --force option"
fi
grep -q 'Unknown option: --force' "$test_tmp/force.out" || fail "helios-migrate reports obsolete --force option"
pass "helios-migrate no longer needs --force"

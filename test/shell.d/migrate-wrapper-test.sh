#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_root="$test_tmp/kestrel"
test_home="$test_tmp/home"
stub_bin="$test_tmp/bin"
mkdir -p "$test_root/migrations" "$test_home" "$stub_bin"

cat >"$stub_bin/kestrel-notification-dismiss" <<'SH'
#!/bin/bash
printf '%s\n' "$1" >>"$TEST_DISMISSALS"
SH
chmod +x "$stub_bin/kestrel-notification-dismiss"

cat >"$test_root/migrations/100-migration.sh" <<'SH'
echo migration >>"$TEST_CALLS"
SH

run_migrate() {
  HOME="$test_home" \
  KESTREL_PATH="$test_root" \
  PATH="$stub_bin:$ROOT/bin:$PATH" \
  TEST_CALLS="$test_tmp/calls" \
  TEST_DISMISSALS="$test_tmp/dismissals" \
    "$ROOT/bin/kestrel-migrate" "$@"
}

: >"$test_tmp/calls"
run_migrate >"$test_tmp/migrate.out"
[[ $(sed -n '1p' "$test_tmp/calls") == "migration" ]] || fail "kestrel-migrate runs pending migrations"
pass "kestrel-migrate runs migrations without force"

grep -Fx 'Kestrel Migrations' "$test_tmp/dismissals" >/dev/null || fail "kestrel-migrate dismisses migration notifications"
pass "kestrel-migrate clears completed migration notifications"

rm -rf "$test_home/.local/state/kestrel/migrations"
run_migrate --pending >"$test_tmp/pending.out"
grep -q '^100-migration\.sh$' "$test_tmp/pending.out" || fail "kestrel-migrate --pending lists pending migrations"
pass "kestrel-migrate --pending lists pending migrations"

run_migrate >"$test_tmp/migrate-second.out"
if run_migrate --pending >"$test_tmp/not-pending.out"; then
  fail "kestrel-migrate --pending exits non-zero without pending migrations"
fi
[[ ! -s $test_tmp/not-pending.out ]] || fail "kestrel-migrate --pending stays quiet without pending migrations"
pass "kestrel-migrate --pending reports no pending migrations"

if run_migrate --force >"$test_tmp/force.out" 2>&1; then
  fail "kestrel-migrate rejects obsolete --force option"
fi
grep -q 'Unknown option: --force' "$test_tmp/force.out" || fail "kestrel-migrate reports obsolete --force option"
pass "kestrel-migrate no longer needs --force"

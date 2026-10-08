#!/bin/bash

set -euo pipefail

# The migration hands an existing Hermes Desktop install the HeliOS skin. It
# is exercised here with the package probe and the skin hook stubbed, so a
# migration that reached a Hermes HeliOS did not install, or that marked a
# failed hand-over done, shows up in what it ran.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1788619462.sh"
[[ -f $migration ]] || fail "Hermes skin migration exists"
[[ $(stat -c %a "$migration") == "644" ]] || fail "migration is a plain 0644 file"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
calls="$test_tmp/calls"
mkdir -p "$mock_bin"

cat >"$mock_bin/helios-pkg-present" <<'SH'
#!/bin/bash
[[ $1 == "hermes-desktop" && ${HELIOS_TEST_DESKTOP_INSTALLED:-0} == 1 ]]
SH

cat >"$mock_bin/helios-theme-set-hermes" <<'SH'
#!/bin/bash
echo "helios-theme-set-hermes $*" >>"$HELIOS_TEST_CALLS"
[[ ${HELIOS_TEST_HOOK_FAILS:-0} == 0 ]]
SH

chmod +x "$mock_bin"/*

run_migration() {
  : >"$calls"
  HELIOS_TEST_DESKTOP_INSTALLED="${HELIOS_TEST_DESKTOP_INSTALLED:-1}" \
    HELIOS_TEST_HOOK_FAILS="${HELIOS_TEST_HOOK_FAILS:-0}" \
    HELIOS_TEST_CALLS="$calls" \
    PATH="$mock_bin:$PATH" \
    HOME="$test_tmp/home" \
    HELIOS_PATH="$ROOT" \
    bash -euo pipefail "$migration" >/dev/null
}

HELIOS_TEST_DESKTOP_INSTALLED=0 run_migration || fail "migration exits clean without Hermes Desktop"
[[ ! -s $calls ]] || fail "a machine without Hermes Desktop is left alone" "$(cat "$calls")"
pass "migration only applies where HeliOS installed Hermes Desktop"

run_migration || fail "migration exits clean with Hermes Desktop installed"
[[ $(cat "$calls") == "helios-theme-set-hermes --activate" ]] ||
  fail "the skin is rendered, published and activated through the hook's deliberate form" "$(cat "$calls")"
pass "migration hands the skin over through the hook"

if HELIOS_TEST_HOOK_FAILS=1 run_migration; then
  fail "a hand-over that failed on HeliOS's side stays pending"
fi
pass "migration stays pending when the hand-over fails"

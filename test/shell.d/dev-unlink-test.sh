#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
log_file="$test_tmp/dev-unlink.log"
conf_file="$test_tmp/helios.conf"
mkdir -p "$stub_bin" "$test_tmp/home"

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo' >>"$HELIOS_DEV_UNLINK_TEST_LOG"
for arg in "$@"; do
  printf '\t%s' "$arg" >>"$HELIOS_DEV_UNLINK_TEST_LOG"
done
printf '\n' >>"$HELIOS_DEV_UNLINK_TEST_LOG"

if [[ $1 == "tee" ]]; then
  cat >"$HELIOS_DEV_UNLINK_TEST_CONF"
fi
SH
chmod +x "$stub_bin/sudo"

cat >"$stub_bin/gum" <<'SH'
#!/bin/bash

printf 'gum' >>"$HELIOS_DEV_UNLINK_TEST_LOG"
for arg in "$@"; do
  printf '\t%s' "$arg" >>"$HELIOS_DEV_UNLINK_TEST_LOG"
done
printf '\n' >>"$HELIOS_DEV_UNLINK_TEST_LOG"
SH
chmod +x "$stub_bin/gum"

cat >"$stub_bin/helios-system-reboot" <<'SH'
#!/bin/bash

printf 'reboot\n' >>"$HELIOS_DEV_UNLINK_TEST_LOG"
SH
chmod +x "$stub_bin/helios-system-reboot"

run_unlink() {
  HOME="$test_tmp/home" \
    HELIOS_DEV_UNLINK_TEST_LOG="$log_file" \
    HELIOS_DEV_UNLINK_TEST_CONF="$conf_file" \
    PATH="$stub_bin:$PATH" \
    "$ROOT/bin/helios-dev-unlink" "$@"
}

: >"$log_file"
run_unlink --no-reboot

grep -Fx $'sudo\ttee\t/etc/helios.conf' "$log_file" >/dev/null ||
  fail "dev unlink writes the package path without rebooting" "$(cat "$log_file")"
[[ $(<"$conf_file") == 'export HELIOS_PATH="/usr/share/helios"' ]] ||
  fail "dev unlink writes the package path guard" "$(<"$conf_file")"

# Left behind, it keeps sudo running a checkout nothing else points at.
grep -Fx $'sudo\trm\t-f\t/etc/sudoers.d/helios-dev-path' "$log_file" >/dev/null ||
  fail "dev unlink drops the sudo secure_path drop-in" "$(cat "$log_file")"
pass "dev unlink drops the sudo secure_path drop-in"

if grep -Eq '^(gum|reboot)' "$log_file"; then
  fail "dev unlink --no-reboot skips the reboot prompt" "$(cat "$log_file")"
fi
pass "dev unlink --no-reboot skips the reboot prompt"

: >"$log_file"
run_unlink

grep -Fx $'gum\tconfirm\tReboot now to activate?' "$log_file" >/dev/null ||
  fail "interactive dev unlink still prompts for reboot" "$(cat "$log_file")"
grep -Fx 'reboot' "$log_file" >/dev/null ||
  fail "interactive dev unlink still reboots after confirmation" "$(cat "$log_file")"
pass "interactive dev unlink keeps its reboot prompt"

if run_unlink --invalid >"$test_tmp/invalid.out" 2>"$test_tmp/invalid.err"; then
  fail "dev unlink rejects unknown arguments"
fi
grep -F 'Usage: helios dev unlink [--no-reboot]' "$test_tmp/invalid.err" >/dev/null ||
  fail "dev unlink explains valid arguments" "$(cat "$test_tmp/invalid.err")"
pass "dev unlink rejects unknown arguments"

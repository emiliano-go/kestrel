#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
rm "$SUDO_TEST_ROOT/bin/helios-update-restart"
copy_boundary_file bin/helios-update-restart
for step in helios-state helios-restart-sshd helios-restart-shell helios-system-reboot; do
  ln -s test-step "$SUDO_TEST_ROOT/bin/$step"
done
cat >"$SUDO_TEST_ROOT/bin/gum" <<'STUB'
#!/bin/bash
printf 'prompt:%s\n' "$*" >>"$SUDO_TEST_LOG"
exit 1
STUB
chmod +x "$SUDO_TEST_ROOT/bin/gum"
mkdir -p "$SUDO_TEST_HOME/.local/state/helios"
touch "$SUDO_TEST_HOME/.local/state/helios/reboot-required" "$SUDO_TEST_HOME/.local/state/helios/restart-sshd-required"

for mode in --services-only --reboot-only; do
  reset_boundary
  PATH="$SUDO_TEST_ROOT/bin:$PATH" "$SUDO_TEST_ROOT/bin/helios-update-restart" "$mode" >"$boundary_tmp/output" 2>&1
  if [[ $mode == "--services-only" ]]; then
    grep -q '^step:helios-restart-sshd ' "$SUDO_TEST_LOG" || fail "service phase did not restart a marked service"
    grep -q '^step:helios-restart-shell ' "$SUDO_TEST_LOG" || fail "service phase did not restart the shell"
    if grep -q '^prompt:' "$SUDO_TEST_LOG"; then fail "service phase offered a reboot before update cleanup"; fi
  else
    grep -q '^prompt:' "$SUDO_TEST_LOG" || fail "reboot phase did not offer the required reboot"
    if grep -q '^step:helios-restart-' "$SUDO_TEST_LOG"; then fail "reboot phase performed later service work"; fi
  fi
  pass "restart $mode performs only its selected phase"
done
reset_boundary
HELIOS_UPDATE_UNATTENDED=1 PATH="$SUDO_TEST_ROOT/bin:$PATH" "$SUDO_TEST_ROOT/bin/helios-update-restart" --reboot-only >"$boundary_tmp/output" 2>&1
if grep -Eq "^(prompt:|step:helios-restart-|step:helios-system-reboot)" "$SUDO_TEST_LOG"; then
  fail "unattended reboot phase prompted or performed service work"
fi
pass "unattended reboot phase reports a required reboot without prompting"

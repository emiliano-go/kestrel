#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
copy_boundary_file bin/kestrel-update
test_tmp="$boundary_tmp"
stub_bin="$SUDO_TEST_ROOT/bin"

# Every step kestrel-update runs, recorded in order with the unattended flag it
# was handed. One of them can be told to fail.
steps=(
  kestrel-update-lock
  kestrel-update-requires-free-space
  kestrel-update-confirm
  kestrel-update-pkg-prune
  kestrel-snapshot
  kestrel-update-stay-awake
  kestrel-update-dev
  kestrel-update-keyring
  kestrel-update-system-pkgs
  kestrel-migrate
  kestrel-hook
  kestrel-update-aur-pkgs
  kestrel-update-mise
  kestrel-update-orphan-pkgs
  kestrel-update-analyze-logs
  kestrel-update-status
  kestrel-update-restart
)

for step in "${steps[@]}"; do
  rm -f "$stub_bin/$step"
  cat >"$stub_bin/$step" <<'STUB'
#!/bin/bash
printf '%s unattended=%s\n' "${0##*/}" "${KESTREL_UPDATE_UNATTENDED:-}" >>"$STEP_LOG"
if [[ ${0##*/} == "kestrel-update-orphan-pkgs" ]]; then
  printf '%s\n' "$@" >"$STEP_LOG.orphan-args"
fi
[[ ${FAILING_STEP:-} != "${0##*/}" ]] || exit 1
STUB
  chmod +x "$stub_bin/$step"
done

# KESTREL_UPDATE_LOGGED stands in for the script(1) wrapper the update re-execs
# itself under; the stubbed lock reports itself already held.
run_update() {
  : >"$test_tmp/steps"
  STEP_LOG="$test_tmp/steps" \
    FAILING_STEP="${FAILING_STEP:-}" \
    KESTREL_UPDATE_LOGGED=1 \
    PATH="$stub_bin:$PATH" \
    "$SUDO_TEST_ROOT/bin/kestrel-update" "$@" >"$test_tmp/out" 2>"$test_tmp/err"
}

steps_run() {
  cut -d' ' -f1 "$test_tmp/steps"
}

# Every step of a whole update, in order. $1 asks for the one a person confirms.
# Stay Awake bookends the work, so it is here twice.
expected_steps() {
  printf '%s\n' \
    kestrel-update-lock \
    kestrel-update-requires-free-space \
    ${1:+kestrel-update-confirm} \
    kestrel-update-pkg-prune \
    kestrel-snapshot \
    kestrel-update-stay-awake \
    kestrel-update-dev \
    kestrel-update-keyring \
    kestrel-update-system-pkgs \
    kestrel-migrate \
    kestrel-update-orphan-pkgs \
    kestrel-update-analyze-logs \
    kestrel-update-status \
    kestrel-update-restart \
    kestrel-hook \
    kestrel-update-mise \
    kestrel-update-aur-pkgs \
    kestrel-update-stay-awake \
    kestrel-update-restart
}

run_update -y || fail "an update where everything works reports a failure"
diff <(expected_steps) <(steps_run) >"$test_tmp/order" ||
  fail "an update where everything works does not run every step in order" "$(cat "$test_tmp/order")"
pass "an update where every step works runs all of them, in order"
[[ $(cat "$test_tmp/steps.orphan-args") == "-y" ]] || fail "an unattended update approves orphan removal"
pass "an unattended update approves orphan removal"

grep -q '^kestrel-update-system-pkgs unattended=1$' "$test_tmp/steps" ||
  fail "-y does not mark the update unattended"
run_update </dev/null || fail "a confirmed update reports a failure"
diff <(expected_steps confirmed) <(steps_run) >"$test_tmp/order" ||
  fail "a confirmed update runs a different set of steps" "$(cat "$test_tmp/order")"
grep -q '^kestrel-update-system-pkgs unattended=$' "$test_tmp/steps" ||
  fail "an update a person confirmed is treated as unattended"
pass "-y is what marks an update unattended, not the update itself"
[[ $(cat "$test_tmp/steps.orphan-args") == "-y" ]] || fail "a confirmed update approves orphan removal"
pass "a confirmed update approves orphan removal"

# Migrations ship with the packages the upgrade installs and are written against
# them. Running them against what is still on disk is the failure this ordering
# exists to prevent, so the update stops where the packages did.
if FAILING_STEP=kestrel-update-system-pkgs run_update -y; then
  fail "an update whose packages did not upgrade passes for a whole one"
fi
for step in kestrel-migrate kestrel-hook kestrel-update-aur-pkgs kestrel-update-restart; do
  if grep -q "^$step " "$test_tmp/steps"; then
    fail "a blocked package upgrade still runs $step"
  fi
done
pass "a blocked package upgrade stops the update before it migrates"

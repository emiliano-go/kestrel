#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
mkdir -p "$TMPDIR/home" "$TMPDIR/bin"
calls="$TMPDIR/calls"

cat >"$TMPDIR/bin/kestrel-shell" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$KESTREL_TEST_CALLS"
printf 'ok\n'
SH
chmod +x "$TMPDIR/bin/kestrel-shell"

run_enable() {
  HOME="$TMPDIR/home" \
    KESTREL_PATH="$ROOT" \
    KESTREL_TEST_CALLS="$calls" \
    PATH="$TMPDIR/bin:$ROOT/bin:$PATH" \
    kestrel-plugin-enable "$@"
}

run_enable kestrel.active-window --section right >/dev/null
grep -Fqx 'shell enablePlugin kestrel.active-window {"section":"right"}' "$calls" ||
  fail "plugin enable did not combine activation and placement"
pass "plugin enable combines activation and placement in one shell mutation"

run_enable kestrel.clock --before kestrel.weather >/dev/null
grep -Fqx 'shell enablePlugin kestrel.clock {"before":"kestrel.weather"}' "$calls" ||
  fail "plugin enable did not preserve relative placement"
pass "plugin enable forwards relative placement"

run_enable kestrel.dropbox >/dev/null
grep -Fqx 'shell enablePlugin kestrel.dropbox {}' "$calls" ||
  fail "plugin enable did not use manifest-default placement"
pass "plugin enable leaves default placement to the registry"

if run_enable kestrel.bar --section right >/dev/null 2>&1; then
  fail "plugin enable accepted placement for a full bar"
fi
pass "plugin enable rejects placement for full bars"

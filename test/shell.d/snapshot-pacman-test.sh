#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

snapshot="$ROOT/bin/kestrel-snapshot"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

fake_bin="$test_tmp/bin"
mkdir -p "$fake_bin"

cat >"$fake_bin/kestrel-cmd-missing" <<'STUB'
#!/bin/bash
exit 1
STUB
chmod +x "$fake_bin/kestrel-cmd-missing"

# The pacman hook runs as root, so reaching for sudo here would be a bug.
cat >"$fake_bin/sudo" <<'STUB'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$TEST_LOG"
exec "$@"
STUB
chmod +x "$fake_bin/sudo"

cat >"$fake_bin/snapper" <<'STUB'
#!/bin/bash
printf 'snapper %s\n' "$*" >>"$TEST_LOG"
if [[ "$*" == *"list-configs"* ]]; then
  printf 'config,subvolume\nroot,/\n'
fi
STUB
chmod +x "$fake_bin/snapper"

: >"$test_tmp/calls.log"
TEST_LOG="$test_tmp/calls.log" PATH="$fake_bin:$PATH" bash "$snapshot" pacman

grep -qE '^snapper -c root create -c number -d pacman ' "$test_tmp/calls.log" ||
  fail "pacman snapshot records a snapshot after an upgrade" "$(cat "$test_tmp/calls.log")"
grep -qFx 'snapper -c root cleanup number' "$test_tmp/calls.log" ||
  fail "pacman snapshot trims to the retention limit" "$(cat "$test_tmp/calls.log")"
! grep -q '^sudo ' "$test_tmp/calls.log" ||
  fail "pacman snapshot runs without sudo (the hook is already root)"
pass "pacman snapshot creates and trims without sudo"

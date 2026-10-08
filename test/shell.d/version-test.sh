#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

# The edge channel installs helios-dev. Older builds did not declare
# provides=(helios), so a query for plain helios finds nothing there.
cat >"$stub_bin/pacman" <<'STUB'
#!/bin/bash
[[ $1 == "-Q" ]] || exit 1
shift
for package in "$@"; do
  case ",${HELIOS_TEST_PACKAGES:-}," in
    *",$package,"*)
      echo "$package ${HELIOS_TEST_VERSION:-4.0.0-1}"
      exit 0
      ;;
  esac
done
echo "error: package '$1' was not found" >&2
exit 1
STUB
chmod +x "$stub_bin/pacman"

version() {
  HELIOS_TEST_PACKAGES="$1" \
    HELIOS_PATH="${2:-/usr/share/helios}" \
    PATH="$stub_bin:$PATH" \
    "$ROOT/bin/helios-version"
}

[[ $(version helios) == "4.0.0-1" ]] || fail "version reports the stable package"
pass "version reports the stable package"

[[ $(version helios-dev) == "4.0.0-1" ]] || fail "version reports the edge package"
pass "version reports the edge package"

# A checkout reports its hash instead, so packages are irrelevant there.
[[ $(version "" "$test_tmp/checkout") == "dev" ]] || fail "version reports a dev checkout"
pass "version reports a dev checkout"

if version "" >/dev/null 2>&1; then
  fail "version fails when no HeliOS package is installed"
fi
pass "version fails when no HeliOS package is installed"

# The snapshot description is only a label, so a failed lookup must not abort
# the update under set -e.
snapshot_desc=$(
  set -e
  PATH="$stub_bin:$PATH" HELIOS_TEST_PACKAGES="" HELIOS_PATH=/usr/share/helios \
    bash -c 'DESC="$(helios-version 2>/dev/null || echo unknown)"; echo "$DESC"' 2>/dev/null
) || fail "snapshot survives an unknown version"

[[ $snapshot_desc == "unknown" ]] || fail "snapshot labels an unknown version" "actual: $snapshot_desc"
pass "snapshot survives an unknown version"

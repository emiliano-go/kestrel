#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

export PATH="$ROOT/bin:$PATH"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

mock_bin="$TMPDIR/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/kestrel-cmd-present" <<'SH'
#!/bin/bash
set -euo pipefail

case "${1:-}" in
  dropbox-cli)
    [[ ${KESTREL_TEST_DROPBOX_CLI:-0} == "1" ]]
    ;;
  tailscale)
    [[ ${KESTREL_TEST_TAILSCALE_CLI:-0} == "1" ]]
    ;;
  *)
    command -v "${1:-}" >/dev/null 2>&1
    ;;
esac
SH

cat >"$mock_bin/dropbox-cli" <<'SH'
#!/bin/bash
set -euo pipefail

[[ ${KESTREL_TEST_DROPBOX_RUNNING:-0} == "1" && ${1:-} == "running" ]]
SH

cat >"$mock_bin/tailscale" <<'SH'
#!/bin/bash
set -euo pipefail

[[ ${KESTREL_TEST_TAILSCALE_STATUS:-0} == "1" && ${1:-} == "status" && ${2:-} == "--json" ]]
SH

cat >"$mock_bin/systemctl" <<'SH'
#!/bin/bash
set -euo pipefail

[[ ${KESTREL_TEST_TAILSCALE_SYSTEMD:-0} == "1" ]]
SH

cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
set -euo pipefail

if (( $# == 0 )); then
  exit 1
fi

name="${!#}"
case "$name" in
  dropbox)
    [[ ${KESTREL_TEST_DROPBOX_PROCESS:-0} == "1" ]]
    ;;
  tailscaled)
    [[ ${KESTREL_TEST_TAILSCALE_PROCESS:-0} == "1" ]]
    ;;
  *)
    exit 1
    ;;
esac
SH

chmod +x "$mock_bin"/*
mock_path="$mock_bin:$ROOT/bin:$PATH"

PATH="$mock_path" KESTREL_TEST_DROPBOX_CLI=1 KESTREL_TEST_DROPBOX_RUNNING=1 kestrel-installed-service-dropbox
pass "installed Dropbox service check accepts running CLI"

PATH="$mock_path" KESTREL_TEST_DROPBOX_PROCESS=1 kestrel-installed-service-dropbox
pass "installed Dropbox service check accepts running process"

if PATH="$mock_path" kestrel-installed-service-dropbox; then
  fail "installed Dropbox service check rejects unavailable service"
fi
pass "installed Dropbox service check rejects unavailable service"

PATH="$mock_path" KESTREL_TEST_TAILSCALE_CLI=1 KESTREL_TEST_TAILSCALE_STATUS=1 kestrel-installed-service-tailscale
pass "installed Tailscale service check accepts status JSON"

PATH="$mock_path" KESTREL_TEST_TAILSCALE_SYSTEMD=1 kestrel-installed-service-tailscale
pass "installed Tailscale service check accepts active systemd service"

PATH="$mock_path" KESTREL_TEST_TAILSCALE_PROCESS=1 kestrel-installed-service-tailscale
pass "installed Tailscale service check accepts running daemon"

if PATH="$mock_path" kestrel-installed-service-tailscale; then
  fail "installed Tailscale service check rejects unavailable service"
fi
pass "installed Tailscale service check rejects unavailable service"

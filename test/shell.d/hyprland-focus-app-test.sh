#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/mmsg" <<'SH'
#!/bin/bash
if [[ $1 == "get" ]]; then
  printf '%s\n' "$KESTREL_TEST_CLIENTS_JSON"
elif [[ $1 == "dispatch" ]]; then
  printf '%s\n' "$2 $3" >"$KESTREL_TEST_FOCUS_DISPATCH"
fi
SH
chmod +x "$mock_bin/mmsg"

dispatch_log="$test_tmp/dispatch"
clients_json='{"clients":[{"id":7,"appid":"chromium","title":""}]}'
PATH="$mock_bin:$PATH" KESTREL_TEST_CLIENTS_JSON="$clients_json" \
  KESTREL_TEST_FOCUS_DISPATCH="$dispatch_log" \
  bash "$ROOT/bin/kestrel-hyprland-focus-app" '^chromium$'

grep -F 'focusid client,7' "$dispatch_log" >/dev/null || \
  fail "app focus follows windows across tags"

pass "app focus follows windows across tags"

clients_json='{"clients":[
  {"id":10,"appid":"com.viber.Viber","title":"Viber"},
  {"id":11,"appid":"org.kestrel.agent","title":"kitty"}
]}'
PATH="$mock_bin:$PATH" KESTREL_TEST_CLIENTS_JSON="$clients_json" \
  KESTREL_TEST_FOCUS_DISPATCH="$dispatch_log" \
  bash "$ROOT/bin/kestrel-hyprland-focus-app" kitty

grep -F 'focusid client,11' "$dispatch_log" >/dev/null || \
  fail "app focus falls back to the window title"

pass "app focus finds terminals launched under a shared agent app id"

clients_json='{"clients":[
  {"id":12,"appid":"chromium","title":"Mail settings"}
]}'
rm -f "$dispatch_log"
if PATH="$mock_bin:$PATH" KESTREL_TEST_CLIENTS_JSON="$clients_json" \
  KESTREL_TEST_FOCUS_DISPATCH="$dispatch_log" \
  bash "$ROOT/bin/kestrel-hyprland-focus-app" Mail; then
  fail "app focus rejects title matches from non-agent windows"
fi

[[ ! -e $dispatch_log ]] || fail "app focus leaves focus unchanged for unrelated title matches"

pass "app focus restricts title matching to agent terminals"

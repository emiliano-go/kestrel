#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

home="$tmpdir/home"
kestrel_path="$tmpdir/kestrel"

mkdir -p "$home/.config/hypr" "$kestrel_path/config/hypr"

cat >"$kestrel_path/config/hypr/bindings.lua" <<'EOF'
-- refreshed from KESTREL_PATH
EOF

cat >"$home/.config/hypr/bindings.lua" <<'EOF'
-- existing user config
EOF

HOME="$home" KESTREL_PATH="$kestrel_path" "$ROOT/bin/kestrel-refresh-config" hypr/bindings.lua >/dev/null

cmp -s "$kestrel_path/config/hypr/bindings.lua" "$home/.config/hypr/bindings.lua" ||
  fail "refresh-config copies from KESTREL_PATH/config"

backup=$(find "$home/.config/hypr" -name 'bindings.lua.bak.*' -print -quit)
[[ -n $backup ]] || fail "refresh-config backs up replaced user config"
grep -Fq -- '-- existing user config' "$backup" ||
  fail "refresh-config backup contains previous user config"

pass "refresh-config copies from KESTREL_PATH/config and backs up existing files"

if HOME="$home" KESTREL_PATH="$kestrel_path" "$ROOT/bin/kestrel-refresh-config" hypr/missing.lua >"$tmpdir/out" 2>"$tmpdir/err"; then
  fail "refresh-config rejects configs missing from KESTREL_PATH/config"
fi

grep -Fq 'Not a shipped user config: hypr/missing.lua' "$tmpdir/err" ||
  fail "refresh-config reports missing shipped config"

pass "refresh-config validates against KESTREL_PATH/config"

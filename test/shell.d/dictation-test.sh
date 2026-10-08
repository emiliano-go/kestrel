#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export HOME="$test_tmp/home" XDG_CONFIG_HOME="$test_tmp/config" HELIOS_PATH="$ROOT"
export DICTATION_LOG="$test_tmp/calls" DICTATION_INSTALLED="voxtype superwhisper"
mkdir -p "$test_tmp/bin" "$XDG_CONFIG_HOME/helios/defaults"
export PATH="$test_tmp/bin:$ROOT/bin:$PATH"
config="$XDG_CONFIG_HOME/helios/defaults/dictation"

cat > "$test_tmp/bin/helios-cmd-present" <<'SH'
#!/bin/bash
case "$1" in
  helios-dictation-*|helios-install-dictation-*) command -v "$1" >/dev/null ;;
  *) [[ " $DICTATION_INSTALLED " == *" $1 "* ]] ;;
esac
SH
cat > "$test_tmp/bin/helios-cmd-missing" <<'SH'
#!/bin/bash
! helios-cmd-present "$1"
SH
cat > "$test_tmp/bin/helios-launch-floating-terminal-with-presentation" <<'SH'
#!/bin/bash
printf '%s\n' "$*" > "$DICTATION_INSTALL_LOG"
SH
export DICTATION_INSTALL_LOG="$test_tmp/install"
for backend in voxtype superwhisper; do
  cat > "$test_tmp/bin/$backend" <<'SH'
#!/bin/bash
printf '%s %s\n' "${0##*/}" "$*" >> "$DICTATION_LOG"
if [[ $1 == "status" ]]; then echo "${VOXTYPE_STATUS:-idle}"; exit 0; fi
if [[ -n ${FAIL_SETUP_STEP:-} && $* == "$FAIL_SETUP_STEP" ]]; then exit 7; fi
if [[ ${0##*/} == "superwhisper" && $1 == "shortcuts" && ${DICTATION_EXIT:-0} == 0 ]]; then
  if [[ $2 == "show" ]]; then
    cat "$SHORTCUT_STATE"
  elif [[ $2 == "set" ]]; then
    chord=$4
    [[ $chord != "none" ]] || chord=""
    updated=$(jq --arg action "$3" --arg chord "$chord" '.shortcuts[$action] = $chord' "$SHORTCUT_STATE")
    jq -e '.shortcuts | .hold != "RightAlt" and (.hold != "" or .toggle != "")' <<< "$updated" >/dev/null || exit 1
    printf '%s\n' "$updated" > "$SHORTCUT_STATE"
  fi
fi
exit "${DICTATION_EXIT:-0}"
SH
done
for command in helios-pkg-add helios-notification-send hyprctl helios-restart-shell; do
  cat > "$test_tmp/bin/$command" <<'SH'
#!/bin/bash
printf '%s %s\n' "${0##*/}" "$*" >> "$DICTATION_LOG"
exit "${SETUP_EXIT:-0}"
SH
done
cat > "$test_tmp/bin/systemctl" <<'SH'
#!/bin/bash
if [[ $* == "--user is-active --quiet superwhisper.service" ]]; then
  [[ ${DICTATION_SERVICE_ACTIVE:-1} == 1 ]]
else
  printf '%s %s\n' "${0##*/}" "$*" >> "$DICTATION_LOG"
  exit "${SERVICE_EXIT:-0}"
fi
SH
cat > "$test_tmp/bin/helios-hw-vulkan" <<'SH'
#!/bin/bash
exit 1
SH
cat > "$test_tmp/bin/gum" <<'SH'
#!/bin/bash
exit "${CONFIRM_EXIT:-0}"
SH
cat > "$test_tmp/bin/bash" <<'SH'
#!/bin/bash
if [[ $1 == "/usr/share/superwhisper/setup-user" ]]; then
  printf '%s\n' setup-user >> "$DICTATION_LOG"
  exit "${SETUP_EXIT:-0}"
else
  exec /bin/bash "$@"
fi
SH
chmod +x "$test_tmp/bin/"*

if helios-dictation start 2> "$test_tmp/error"; then
  fail "unset backend must fail even when providers are installed"
fi
[[ ! -e $DICTATION_LOG ]] || fail "recording never configures or installs a backend"
pass "dictation requires explicit configuration"
helios-default-dictation superwhisper
[[ $(cat "$DICTATION_INSTALL_LOG") == "helios-install-dictation-superwhisper" ]] || fail "Defaults launches backend installer"
[[ ! -e $config ]] || fail "Defaults does not select before setup succeeds"
if helios-default-dictation unknown > "$test_tmp/output" 2>&1; then fail "missing installer must fail"; fi
if helios-default-dictation '../invalid' > "$test_tmp/output" 2>&1; then fail "invalid backend must fail"; fi
pass "Defaults delegates setup without prematurely selecting a backend"


for backend in voxtype superwhisper; do
  printf '%s\n' "$backend" > "$config"
  [[ $(helios-default-dictation) == "$backend" ]] || fail "configured backend is readable"
  : > "$DICTATION_LOG"
  for action in start stop toggle; do helios dictation "$action"; done
  if [[ $backend == "voxtype" ]]; then
    expected=$'voxtype record start\nvoxtype status\nvoxtype record stop\nvoxtype record toggle'
  else
    expected=$'superwhisper start\nsuperwhisper stop\nsuperwhisper record'
  fi
  [[ $(cat "$DICTATION_LOG") == "$expected" ]] || fail "adapter dispatches recording for $backend"
done
pass "built-in adapters implement start stop and toggle"

cat > "$test_tmp/bin/helios-dictation-future-backend" <<'SH'
#!/bin/bash
[[ ! -e /proc/$$/fd/9 ]] || exit 90
printf '%s\n' "$1" >> "$DICTATION_LOG"
exit "${DICTATION_EXIT:-0}"
SH
chmod +x "$test_tmp/bin/helios-dictation-future-backend"
cat > "$test_tmp/bin/helios-install-dictation-future-backend" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$test_tmp/bin/helios-install-dictation-future-backend"
helios-default-dictation future-backend
[[ $(cat "$DICTATION_INSTALL_LOG") == "helios-install-dictation-future-backend" ]] || fail "third backend installer requires no selector changes"
printf '%s\n' future-backend > "$config"
: > "$DICTATION_LOG"
for action in start stop toggle; do helios-dictation "$action"; done
[[ $(cat "$DICTATION_LOG") == $'start\nstop\ntoggle' ]] || fail "third backend requires no dispatcher changes"
result=0
DICTATION_EXIT=7 helios-dictation start || result=$?
(( result == 7 )) || fail "backend failures propagate"
rm "$test_tmp/bin/helios-dictation-future-backend"
if helios-dictation start 2> "$test_tmp/error"; then fail "missing adapter must fail"; fi
printf '%s\n' '../invalid' > "$config"
if helios-dictation start 2> "$test_tmp/error"; then fail "invalid backend must fail"; fi
pass "external adapters follow the same protocol and errors propagate"

printf '%s\n' voxtype > "$config"
export SHORTCUT_STATE="$test_tmp/shortcuts.json"
printf '%s\n' '{"shortcuts":{"hold":"RightAlt","toggle":"","cancel":"Escape"}}' > "$SHORTCUT_STATE"
if SETUP_EXIT=1 helios-install-dictation-superwhisper > "$test_tmp/output" 2>&1; then fail "failed installation must fail"; fi
[[ $(cat "$config") == "voxtype" ]] || fail "failed setup must preserve selection"
if DICTATION_EXIT=7 helios-install-dictation-superwhisper > "$test_tmp/output" 2>&1; then fail "failed shortcut setup must fail"; fi
[[ $(cat "$config") == "voxtype" ]] || fail "failed shortcuts must preserve selection"
helios-install-dictation-superwhisper
[[ $(helios-default-dictation) == "superwhisper" ]] || fail "installer selects Superwhisper"
jq -e '.shortcuts | .hold == "" and .toggle == "Alt+Space"' "$SHORTCUT_STATE" >/dev/null || fail "installer repairs conflicting hold-only profiles"
printf '%s\n' '{"shortcuts":{"hold":"RightAlt","toggle":"RightSuper","cancel":"Escape"}}' > "$SHORTCUT_STATE"
helios-install-dictation-superwhisper
jq -e '.shortcuts | .hold == "" and .toggle == "Alt+Space"' "$SHORTCUT_STATE" >/dev/null || fail "installer repairs conflicting profiles with an existing toggle"
helios-install-dictation-superwhisper
pass "Superwhisper installer owns setup and saves selection only after success"

DICTATION_INSTALLED=superwhisper
CONFIRM_EXIT=1 helios-install-dictation-voxtype
[[ $(cat "$config") == "superwhisper" ]] || fail "cancelled installation preserves selection"
helios-install-dictation-voxtype
[[ $(helios-default-dictation) == "voxtype" ]] || fail "installer selects Voxtype"
DICTATION_INSTALLED="voxtype superwhisper"
: > "$DICTATION_LOG"
helios-install-dictation-voxtype
grep -q 'voxtype setup --download --no-post-install' "$DICTATION_LOG" || fail "installed Voxtype retries model setup"
printf '%s\n' 'custom model configuration' > "$XDG_CONFIG_HOME/voxtype/config.toml"
printf '%s\n' superwhisper > "$config"
for step in 'setup --download --no-post-install' 'setup systemd'; do
  if FAIL_SETUP_STEP="$step" helios-install-dictation-voxtype > "$test_tmp/output" 2>&1; then fail "incomplete setup must fail"; fi
  [[ $(cat "$config") == "superwhisper" ]] || fail "incomplete setup preserves selection"
done
if SERVICE_EXIT=1 helios-install-dictation-voxtype > "$test_tmp/output" 2>&1; then fail "service failure must fail"; fi
[[ $(cat "$config") == "superwhisper" ]] || fail "service failure preserves selection"
helios-install-dictation-voxtype
[[ $(cat "$config") == "voxtype" ]] || fail "retry finishes installed Voxtype setup"
[[ $(cat "$XDG_CONFIG_HOME/voxtype/config.toml") == "custom model configuration" ]] || fail "retry preserves custom configuration"
pass "Voxtype retries incomplete model and service setup without replacing configuration"

: > "$DICTATION_LOG"
if DICTATION_EXIT=7 helios-dictation-use superwhisper > "$test_tmp/output" 2>&1; then fail "failed stop must prevent switching"; fi
[[ $(cat "$config") == "voxtype" ]] || fail "failed stop preserves selection"
helios-dictation-use superwhisper
[[ $(cat "$DICTATION_LOG") == $'voxtype status\nvoxtype record stop\nvoxtype status\nvoxtype record stop' ]] || fail "switch stops the previous backend"
[[ $(cat "$config") == "superwhisper" ]] || fail "successful stop permits switching"
: > "$DICTATION_LOG"
helios-dictation-use superwhisper
[[ ! -s $DICTATION_LOG ]] || fail "reselecting does not interrupt recording"
printf '%s\n' voxtype > "$config"
VOXTYPE_STATUS=stopped helios-dictation-use superwhisper
[[ $(cat "$config") == "superwhisper" ]] || fail "a stopped Voxtype daemon permits switching"
printf '%s\n' superwhisper > "$config"
DICTATION_SERVICE_ACTIVE=0 helios-dictation-use voxtype
[[ $(cat "$config") == "voxtype" ]] || fail "a stopped Superwhisper service permits switching"
printf '%s\n' removed-backend > "$config"
helios-dictation-use voxtype
[[ $(cat "$config") == "voxtype" ]] || fail "a removed adapter permits recovery"
pass "switching stops recordings, preserves failed stops, and recovers unavailable providers"

# Readers may run throughout a switch, but must never observe a truncated file.
(
  for ((i = 0; i < 200; i++)); do
    selection=$(cat "$config")
    [[ $selection == "voxtype" || $selection == "superwhisper" ]] || exit 1
  done
) &
reader=$!
for ((i = 0; i < 20; i++)); do
  helios-dictation-use voxtype
  helios-dictation-use superwhisper
done
wait "$reader" || fail "concurrent readers always see a complete selection"
printf '%s\n' voxtype > "$config"
pass "selection updates are atomic for concurrent readers"

lua <<'LUA'
local root = os.getenv("ROOT")
local configured, bindings = false, {}
o = {
  shell_succeeds = function(command)
    assert(command == "helios-default-dictation")
    return configured
  end,
  bind = function(...) table.insert(bindings, {...}) end,
}
dofile(root .. "/default/hypr/bindings/dictation.lua")
assert(#bindings == 0, "unconfigured dictation leaves application keys available")
configured = true
dofile(root .. "/default/hypr/bindings/dictation.lua")
assert(#bindings == 5, "any configured backend receives the same bindings")
LUA
pass "dictation shortcuts require a selection without limiting backend names"

# Fresh users receive the backend choice through the settings package's skel.
cp "$ROOT/config/helios/defaults/dictation" "$config"
[[ $(helios-default-dictation) == "superwhisper" ]] || fail "fresh users default to Superwhisper"
printf '%s\n' voxtype > "$config"
pass "fresh users get Superwhisper as their default backend"

lua <<'LUA'
local root = os.getenv("ROOT")
package.path = root .. "/?.lua;" .. package.path
package.loaded["default.hypr.paths"] = { config_home = "/config" }
local selected, available, loaded = "superwhisper", true, {}
local missing = false
o = { cmd_missing = function() return missing end }
local real_open, real_popen, real_dofile = io.open, io.popen, dofile
io.popen = function(command)
  assert(command == "helios-default-dictation 2>/dev/null")
  return { read = function() return selected end, close = function() end }
end
io.open = function(path)
  assert(path == "/config/" .. selected .. "/shortcuts.lua")
  if available then return { close = function() end } end
end
dofile = function(path) table.insert(loaded, path) end
local function load_backend()
  package.loaded["default.hypr.dictation-backend"] = nil
  require("default.hypr.dictation-backend")
end
load_backend()
assert(loaded[1] == "/config/superwhisper/shortcuts.lua")
selected, available = "voxtype", false
load_backend()
assert(#loaded == 1, "a backend with no integration should need no config")
selected, available = "future-backend", true
load_backend()
assert(loaded[2] == "/config/future-backend/shortcuts.lua", "integration must not be limited to named providers")
missing = true
load_backend()
assert(#loaded == 2, "an uninstalled backend must not load a stale bridge")
missing = false
dofile = function() error("broken generated bridge") end
load_backend()
assert(#loaded == 2, "a broken bridge must not abort the desktop configuration")
dofile = function(path) table.insert(loaded, path) end
selected = "../../outside"
load_backend()
assert(#loaded == 2, "a backend must not escape the config directory")
selected = nil
load_backend()
assert(#loaded == 2, "no installed backend must leave configuration usable")
io.open, io.popen, dofile = real_open, real_popen, real_dofile
LUA
pass "desktop integration follows the selected backend without personal Hyprland config"

cat > "$test_tmp/bin/systemctl" <<'SH'
#!/bin/bash
exit 0
SH
cat > "$test_tmp/bin/helios-pkg-drop" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >> "$DICTATION_LOG"
exit "${REMOVE_EXIT:-0}"
SH
chmod +x "$test_tmp/bin/systemctl" "$test_tmp/bin/helios-pkg-drop"
helios-remove-dictation-voxtype
[[ ! -e $config ]] || fail "removing Voxtype clears selection"
if helios-default-dictation 2> "$test_tmp/error"; then fail "removal must not auto-select another backend"; fi
pass "removal clears selection without automatic fallback"

cat > "$test_tmp/bin/helios-shell" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >> "$DICTATION_LOG"
SH
chmod +x "$test_tmp/bin/helios-shell"
export XDG_DATA_HOME="$test_tmp/data"
mkdir -p "$HOME/.local/bin" "$XDG_DATA_HOME/superwhisper/app" "$XDG_DATA_HOME/superwhisper/models" "$XDG_CONFIG_HOME/helios/plugins" "$HOME/.agents/skills" "$HOME/.claude/skills"
ln -s /usr/bin/superwhisper "$HOME/.local/bin/superwhisper"
ln -s /opt/superwhisper "$XDG_DATA_HOME/superwhisper/app/current"
ln -s /opt/superwhisper/assets/helios-plugin/superwhisper-panel "$XDG_CONFIG_HOME/helios/plugins/superwhisper-panel"
ln -s /opt/superwhisper/assets/agent-skill/superwhisper "$HOME/.agents/skills/superwhisper"
ln -s /custom/skill "$HOME/.claude/skills/superwhisper"
printf '%s\n' retained > "$XDG_DATA_HOME/superwhisper/models/model"
printf '%s\n' superwhisper > "$config"
if REMOVE_EXIT=1 helios-remove-dictation-superwhisper > "$test_tmp/output" 2>&1; then
  fail "failed package removal must fail"
fi
[[ -L $HOME/.local/bin/superwhisper && $(cat "$config") == "superwhisper" ]] || fail "failed removal preserves selection and links"
helios-remove-dictation-superwhisper
[[ ! -e $config ]] || fail "Superwhisper removal clears its selection"
for link in "$HOME/.local/bin/superwhisper" "$XDG_DATA_HOME/superwhisper/app/current" "$XDG_CONFIG_HOME/helios/plugins/superwhisper-panel" "$HOME/.agents/skills/superwhisper"; do
  [[ ! -L $link ]] || fail "Superwhisper removal unlinks packaged integration"
done
[[ $(readlink "$HOME/.claude/skills/superwhisper") == "/custom/skill" ]] || fail "custom skills are preserved"
[[ -f $XDG_DATA_HOME/superwhisper/models/model ]] || fail "downloaded models are retained"
printf '%s\n' voxtype > "$config"
helios-remove-dictation-superwhisper
[[ $(cat "$config") == "voxtype" ]] || fail "removing Superwhisper preserves another selected backend"
pass "Superwhisper removal clears its selection and owned links while preserving user data and other backends"

cat > "$test_tmp/bin/helios-pkg-present" <<'SH'
#!/bin/bash
[[ ${VOXTYPE_PACKAGE:-0} == 1 && $1 == "voxtype-bin" ]]
SH
chmod +x "$test_tmp/bin/helios-pkg-present"
rm "$config"
VOXTYPE_PACKAGE=0 /bin/bash -euo pipefail "$ROOT/migrations/1791479273.sh"
[[ ! -e $config ]] || fail "migration does not select an uninstalled backend"
VOXTYPE_PACKAGE=1 /bin/bash -euo pipefail "$ROOT/migrations/1791479273.sh"
[[ $(cat "$config") == "voxtype" ]] || fail "existing Voxtype users keep dictation after upgrade"
printf '%s\n' future-backend > "$config"
VOXTYPE_PACKAGE=1 /bin/bash -euo pipefail "$ROOT/migrations/1791479273.sh"
[[ $(cat "$config") == "future-backend" ]] || fail "upgrade preserves explicit backend selections"
pass "one-time upgrade preserves existing Voxtype without runtime autodetection"

#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

shortcuts="$ROOT/default/helios/shortcuts"

# Load the helpers and every default binding against a stub hl, and print one
# line per binding: "global <name>" for a global shortcut, "exec <command>" for
# a command, then its description.
list_bindings() {
  HOME="$(mktemp -d)" HELIOS_PATH="$ROOT" lua <<'LUA'
package.path = os.getenv("HELIOS_PATH") .. "/?.lua;" .. package.path

local function proxy()
  return setmetatable({}, {
    __index = function(self, key)
      local value = proxy()
      rawset(self, key, value)
      return value
    end,
    __call = function()
      return {}
    end,
  })
end

local dsp = proxy()
rawset(dsp, "global", function(name) return { global = name } end)
rawset(dsp, "exec_cmd", function(command) return { exec = command } end)

hl = setmetatable({
  dsp = dsp,
  bind = function(keys, dispatcher, opts)
    local kind, target = "other", ""
    if type(dispatcher) == "table" and dispatcher.global then
      kind, target = "global", dispatcher.global
    elseif type(dispatcher) == "table" and dispatcher.exec then
      kind, target = "exec", dispatcher.exec
    end
    print(kind .. "\t" .. target .. "\t" .. ((opts or {}).description or ""))
  end,
}, {
  __index = function()
    return function() return {} end
  end,
})

require("default.hypr.helpers")

o.bind("A", "listed menu", { menu = "theme" })
o.bind("B", "unlisted menu", { menu = "setup.power" })
o.bind("C", "listed panel", { panel = "helios.emojis" })
o.bind("D", "unlisted panel", { panel = "helios.wifiqr" })
o.bind("E", "listed audio", { audio = "raise" })
o.bind("F", "unlisted audio", { audio = "+1" })
o.bind("I", "listed brightness", { brightness = "raise" })
o.bind("G", "listed ipc", { ipc = "media.next" })
o.bind("H", "unlisted ipc", { ipc = "media.sourceNext" })

for _, file in ipairs({ "utilities", "clipboard", "media" }) do
  dofile(os.getenv("HELIOS_PATH") .. "/default/hypr/bindings/" .. file .. ".lua")
end
LUA
}

bindings=$(list_bindings)

expect_binding() {
  local expected="$1"
  local message="$2"
  grep -Fxq "$expected" <<<"$bindings" || fail "$message: $(grep -F "$(cut -f3 <<<"$expected")" <<<"$bindings")"
}

expect_binding $'global\thelios:menu.theme\tlisted menu' "a listed menu route binds its global shortcut"
expect_binding $'exec\thelios-menu toggle \'setup.power\'\tunlisted menu' "an unlisted menu route falls back to the command"
expect_binding $'global\thelios:panel.helios.emojis\tlisted panel' "a listed panel binds its global shortcut"
expect_binding $'exec\thelios-shell shell toggle \'helios.wifiqr\'\tunlisted panel' "an unlisted panel falls back to the command"
expect_binding $'global\thelios:audio.raise\tlisted audio' "a listed volume key binds its global shortcut"
expect_binding $'exec\thelios-audio-output-volume \'+1\'\tunlisted audio' "an unlisted volume step falls back to the script"
expect_binding $'global\thelios:brightness.raise\tlisted brightness' "a listed brightness key binds its global shortcut"
expect_binding $'global\thelios:ipc.media.next\tlisted ipc' "a listed IPC call binds its global shortcut"
expect_binding $'exec\thelios-shell \'media\' \'sourceNext\'\tunlisted ipc' "an unlisted IPC call falls back to helios-shell"
pass "shell bindings use global shortcuts only for what the shell registers"

# Every default binding that toggles a listed route or panel goes through its
# shortcut, and none toggles one through a command any more.
! grep -E $'^exec\t(helios-menu toggle|helios-shell shell toggle) ' <<<"$bindings" | grep -v $'\tunlisted ' ||
  fail "default bindings toggle menus and panels through global shortcuts"
expect_binding $'global\thelios:menu.root\tHeliOS menu' "SUPER+SPACE opens the menu through its shortcut"
expect_binding $'global\thelios:menu.theme\tTheme menu' "the theme menu binding uses its shortcut"
expect_binding $'global\thelios:panel.helios.clipboard\tClipboard manager' "the clipboard binding uses its shortcut"
expect_binding $'global\thelios:audio.raise\tVolume up' "the volume up key steps the volume in the shell"
expect_binding $'global\thelios:audio.lower\tVolume down' "the volume down key steps the volume in the shell"
expect_binding $'global\thelios:audio.mute-toggle\tMute' "the mute key toggles mute in the shell"
expect_binding $'global\thelios:brightness.raise\tBrightness up' "the brightness up key steps the backlight in the shell"
expect_binding $'global\thelios:brightness.lower\tBrightness down' "the brightness down key steps the backlight in the shell"
expect_binding $'global\thelios:ipc.media.playPause\tPlay' "the play key reaches the media service directly"
expect_binding $'global\thelios:ipc.notifications.dismissOne\tDismiss last notification' "dismissing a notification reaches the service directly"
! grep -E $'^exec\thelios-shell (media|notifications) ' <<<"$bindings" ||
  fail "default media and notification keys reach their services through global shortcuts"
pass "default bindings toggle menus and panels through global shortcuts"

# The shell and the helpers read the same list, in the same format.
while IFS= read -r line; do
  [[ -z $line || $line == \#* ]] && continue
  [[ $line =~ ^(menu|panel|audio|brightness|ipc)\ [^[:space:]]+$ ]] || fail "shortcuts lines are a kind and a target: $line"
  if [[ $line == ipc\ * ]]; then
    [[ $line =~ ^ipc\ (media|notifications)\.[A-Za-z]+$ ]] || fail "ipc shortcuts name a mapped target and method: $line"
  fi
done <"$shortcuts"
grep -q 'path: shell.heliosPath + "/default/helios/shortcuts"' "$ROOT/shell/shell.qml" ||
  fail "the shell registers the shortcuts the helpers bind"
grep -q 'paths.helios_path .. "/default/helios/shortcuts"' "$ROOT/default/hypr/helpers.lua" ||
  fail "the helpers bind the shortcuts the shell registers"
# An ipc shortcut runs the service's own IPC handler, so it behaves exactly as
# the helios-shell call it replaces.
for service in services/media notifications; do
  grep -Pzq 'function runShortcut\(method\) \{\n    if \(typeof ipcHandler\[method\] !== "function"\) return false\n    ipcHandler\[method\]\(\)' "$ROOT/shell/plugins/$service/Service.qml" ||
    fail "$service runs ipc shortcuts through its IPC handler"
  grep -Pzq '(IpcHandler|ShellIpc) \{\n    id: ipcHandler' "$ROOT/shell/plugins/$service/Service.qml" ||
    fail "$service names its IPC handler for shortcuts"
done
pass "the shell and the helpers share one shortcut list"

# Every default menu binding target is a real menu route.
run_node_test <<'JS'
const fs = require('fs')
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')
const entries = menu.parseMenuJsonc(fs.readFileSync(path.join(root, 'default/helios/helios-menu.jsonc'), 'utf8'))
const items = {}
const order = []
for (const entry of entries) { items[entry.id] = entry; order.push(entry.id) }
items.root = items.root || { id: 'root' }

const lines = fs.readFileSync(path.join(root, 'default/helios/shortcuts'), 'utf8').split('\n')
for (const line of lines) {
  const match = /^menu (\S+)$/.exec(line)
  if (!match) continue
  const route = match[1]
  assert(route === 'root' || items[menu.resolveRoute(items, order, route)], `shortcut menu route resolves: ${route}`)
}
JS
pass "every shortcut menu route resolves in the menu"

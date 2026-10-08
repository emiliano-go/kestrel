#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The compositor reports at least one monitor
monitors=$(hyprctl -j monitors | jq 'length')
(( monitors >= 1 )) || fail "compositor reports a monitor"
pass "compositor reports a monitor"

# The HeliOS shell is running and responsive
wait_until "helios-shell responds to ping" 60 helios-shell shell ping

# Core shell plugins are loaded
plugins=$(helios-shell shell listPlugins)
for plugin in \
  helios.audio helios.background helios.bar helios.bluetooth \
  helios.clipboard helios.emojis helios.menu \
  helios.monitor helios.network helios.notifications helios.power \
  helios.reminders helios.weather; do
  [[ $plugins == *"$plugin"* ]] || fail "shell plugin is loaded: $plugin" "loaded plugins: $plugins"
  pass "shell plugin is loaded: $plugin"
done

# The bar and background are actually on screen
wait_until "bar layer is on screen" 30 layer_on_screen "helios-bar"
wait_until "background layer is on screen" 30 layer_on_screen "helios-background"

# Hiding parks the bar off-screen without unmapping its layer surface, and
# revealing brings that same surface back on-screen.
restore_bar_visibility() {
  helios-toggle-bar off >/dev/null 2>&1 || true
}
trap restore_bar_visibility EXIT

helios-toggle-bar on
wait_until "hidden bar layer stays mapped" 15 layer_present "helios-bar"
wait_until "hidden bar layer parks off screen" 15 layer_off_screen "helios-bar"
screenshot "success-bar-hidden"

helios-toggle-bar off
wait_until "revealed bar layer returns on screen" 15 layer_on_screen "helios-bar"
screenshot "success-bar-revealed"
trap - EXIT

# Audio stack is up
wait_until "pipewire is running" 30 wpctl status

# Root filesystem is btrfs as installed
[[ $(findmnt -no FSTYPE /) == "btrfs" ]] || fail "root filesystem is btrfs"
pass "root filesystem is btrfs"

# HeliOS reports its version
helios-version >/dev/null || fail "helios-version works"
pass "helios-version works"

# No failed units, system or user. HELIOS_ACCEPTANCE_IGNORE_UNITS can hold a
# regex of units to overlook (useful on dev machines; a fresh VM should be clean).
failed_units() {
  systemctl "$@" --failed --no-legend --plain | awk '{print $1}' |
    grep -Ev "${HELIOS_ACCEPTANCE_IGNORE_UNITS:-^$}" || true
}

failed_system=$(failed_units --system)
if [[ -n $failed_system ]]; then
  fail "no failed system units" "failed units: $failed_system"
fi
pass "no failed system units"

failed_user=$(failed_units --user)
if [[ -n $failed_user ]]; then
  fail "no failed user units" "failed units: $failed_user"
fi
pass "no failed user units"

screenshot "success-desktop"

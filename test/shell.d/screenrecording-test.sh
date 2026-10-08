#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

stub_bin="$tmp_dir/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/v4l2-ctl" <<'SH'
#!/bin/bash

[[ ${HELIOS_TEST_NO_WEBCAM:-false} == "true" ]] && exit 0

case "$1" in
--list-devices)
  printf '%s\n' "ipu6 (PCI:0000:00:05.0):"
  printf '\t%s\n' "/dev/video0"
  printf '\t%s\n' "/dev/video1"

  if [[ ${HELIOS_TEST_RAW_WEBCAM:-false} != "true" ]]; then
    printf '\n%s\n' "Built-in Webcam: Integrated Camera"
    printf '\t%s\n' "/dev/video42"
    printf '\t%s\n' "/dev/video43"
    printf '\n%s\n' "USB Capture Card: External Camera"
    printf '\t%s\n' "/dev/video2"
  fi

  if [[ ${HELIOS_TEST_DUAL_NODE_WEBCAM:-false} == "true" ]]; then
    printf '\n%s\n' "Dual Node Camera: ISP Wrapper"
    printf '\t%s\n' "/dev/video7"
    printf '\t%s\n' "/dev/video8"
    printf '\n%s\n' "Metadata Only: Sensor"
    printf '\t%s\n' "/dev/video9"
  fi
  ;;
--device)
  case "$2" in
  /dev/video0) device_capability="Video Output" ;;
  /dev/video1) device_capability="Metadata Capture" ;;
  /dev/video7 | /dev/video9) device_capability="Video Output" ;;
  *) device_capability="Video Capture" ;;
  esac

  printf '%s\n' \
    "Driver Info:" \
    $'\tCapabilities     : 0x84a00001' \
    $'\t\tVideo Capture' \
    $'\tDevice Caps      : 0x04200001' \
    $'\t\t'"$device_capability"
  ;;
esac
SH

cat >"$stub_bin/helios-menu-select" <<'SH'
#!/bin/bash

printf '%s\n' "$@" >"$HELIOS_TEST_MENU_ARGS"
printf '%s\n' "$3"
SH

cat >"$stub_bin/helios-capture-screenrecording" <<'SH'
#!/bin/bash

printf '%s\n' "$@" >"$HELIOS_TEST_RECORDER_ARGS"
SH

cat >"$stub_bin/helios-notification-send" <<'SH'
#!/bin/bash

printf '%s\n' "$@" >"$HELIOS_TEST_NOTIFICATION_ARGS"
SH

chmod +x "$stub_bin"/*

export PATH="$stub_bin:$ROOT/bin:$PATH"
# The resize helper anchors to a region file here, so keep it out of the real one
export XDG_RUNTIME_DIR="$tmp_dir"
export HELIOS_TEST_MENU_ARGS="$tmp_dir/menu-args"
export HELIOS_TEST_RECORDER_ARGS="$tmp_dir/recorder-args"
export HELIOS_TEST_NOTIFICATION_ARGS="$tmp_dir/notification-args"

mapfile -t capture_devices < <(helios-capture-webcam-list)
expected_capture_devices=(
  "/dev/video42  Built-in Webcam: Integrated Camera"
  "/dev/video2  USB Capture Card: External Camera"
)

if [[ ${capture_devices[*]} != "${expected_capture_devices[*]}" ]]; then
  fail "webcam detection filters output-only devices and collapses each capture group" \
    "expected: ${expected_capture_devices[*]}\nactual:   ${capture_devices[*]}"
fi
pass "webcam detection filters output-only devices and collapses each capture group"

dual_node=$(HELIOS_TEST_DUAL_NODE_WEBCAM=true helios-capture-webcam-list) ||
  fail "webcam listing exits zero when the trailing device is filtered"
pass "webcam listing exits zero when the trailing device is filtered"

expected_dual_node="/dev/video42  Built-in Webcam: Integrated Camera
/dev/video2  USB Capture Card: External Camera
/dev/video8  Dual Node Camera: ISP Wrapper"
[[ $dual_node == "$expected_dual_node" ]] ||
  fail "webcam detection falls through to a later capture-capable node in a group" "$dual_node"
pass "webcam detection falls through to a later capture-capable node in a group"

if "$ROOT/bin/helios-hw-webcam"; then
  pass "webcam hardware detection succeeds when a capture device is available"
else
  fail "webcam hardware detection succeeds when a capture device is available"
fi

if HELIOS_TEST_RAW_WEBCAM=true "$ROOT/bin/helios-hw-webcam"; then
  fail "webcam hardware detection rejects output-only video devices"
else
  pass "webcam hardware detection rejects output-only video devices"
fi

if HELIOS_TEST_NO_WEBCAM=true "$ROOT/bin/helios-hw-webcam"; then
  fail "webcam hardware detection fails when no video device is available"
else
  pass "webcam hardware detection fails when no video device is available"
fi

if HELIOS_TEST_RAW_WEBCAM=true "$ROOT/bin/helios-capture-screenrecording-with-webcam"; then
  fail "screenrecording webcam picker rejects output-only video devices"
fi
grep -Fx 'No webcam devices found' "$HELIOS_TEST_NOTIFICATION_ARGS" >/dev/null || \
  fail "screenrecording webcam picker reports no capture-capable device"
pass "screenrecording webcam picker rejects output-only video devices"

"$ROOT/bin/helios-capture-screenrecording-with-webcam"

expected_menu_args="$tmp_dir/expected-menu-args"
printf '%s\n' \
  "Select Webcam" \
  "/dev/video42  Built-in Webcam: Integrated Camera" \
  "/dev/video2  USB Capture Card: External Camera" \
  "--" \
  "--width" \
  "520" \
  "--maxheight" \
  "520" >"$expected_menu_args"

if ! cmp -s "$HELIOS_TEST_MENU_ARGS" "$expected_menu_args"; then
  fail "screenrecording webcam picker passes each webcam as a menu option" "$(diff -u "$expected_menu_args" "$HELIOS_TEST_MENU_ARGS")"
fi
pass "screenrecording webcam picker passes each webcam as a menu option"

expected_recorder_args="$tmp_dir/expected-recorder-args"
printf '%s\n' \
  "--with-desktop-audio" \
  "--with-microphone-audio" \
  "--with-webcam" \
  "--webcam-device=/dev/video2" >"$expected_recorder_args"

if ! cmp -s "$HELIOS_TEST_RECORDER_ARGS" "$expected_recorder_args"; then
  fail "screenrecording webcam picker starts recording with selected device" "$(diff -u "$expected_recorder_args" "$HELIOS_TEST_RECORDER_ARGS")"
fi
pass "screenrecording webcam picker starts recording with selected device"

first_webcam=$(helios-capture-webcam-list | sed -n '1s/[[:space:]].*//p')
[[ $first_webcam == "/dev/video42" ]] || fail "screenrecording auto-detection selects the first capture device"
grep -F 'WEBCAM_DEVICE=$(helios-capture-webcam-list' "$ROOT/bin/helios-capture-screenrecording" >/dev/null || \
  fail "screenrecording auto-detection uses capture-capable webcams"
pass "screenrecording auto-detection uses the first capture-capable webcam"

cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash

case $1 in
clients)
  printf '[{"address":"0xabc","title":"%s","size":[%s,%s],"monitor":2}]\n' \
    "${HELIOS_TEST_CLIENT_TITLE:-WebcamOverlay}" \
    "${HELIOS_TEST_CLIENT_WIDTH:-178}" \
    "${HELIOS_TEST_CLIENT_HEIGHT:-200}"
  ;;
monitors)
  printf '[{"id":2,"x":1280,"y":-100,"width":%s,"height":%s,"scale":%s}]\n' \
    "${HELIOS_TEST_MONITOR_WIDTH:-2560}" \
    "${HELIOS_TEST_MONITOR_HEIGHT:-1600}" \
    "${HELIOS_TEST_MONITOR_SCALE:-2}"
  ;;
dispatch)
  printf '%s\n' "$*" >>"$HELIOS_TEST_HYPRCTL_ARGS"
  ;;
esac
SH
chmod +x "$stub_bin/hyprctl"

export HELIOS_TEST_HYPRCTL_ARGS="$tmp_dir/hyprctl-args"

"$ROOT/bin/helios-capture-webcam-resize" smaller

expected_hyprctl_args="$tmp_dir/expected-hyprctl-args"
printf '%s\n' \
  'dispatch hl.dsp.window.resize({ window = "address:0xabc", x = 128, y = 144 })' \
  'dispatch hl.dsp.window.move({ window = "address:0xabc", x = 2392, y = 516 })' >"$expected_hyprctl_args"

if ! cmp -s "$HELIOS_TEST_HYPRCTL_ARGS" "$expected_hyprctl_args"; then
  fail "webcam resize preserves its aspect ratio and corner anchor" "$(diff -u "$expected_hyprctl_args" "$HELIOS_TEST_HYPRCTL_ARGS")"
fi
pass "webcam resize preserves its aspect ratio and corner anchor"

: >"$HELIOS_TEST_HYPRCTL_ARGS"
HELIOS_TEST_MONITOR_WIDTH=1920 \
  HELIOS_TEST_MONITOR_HEIGHT=1080 \
  HELIOS_TEST_MONITOR_SCALE=1 \
  HELIOS_TEST_CLIENT_WIDTH=128 \
  HELIOS_TEST_CLIENT_HEIGHT=144 \
  "$ROOT/bin/helios-capture-webcam-resize" reset

printf '%s\n' \
  'dispatch hl.dsp.window.resize({ window = "address:0xabc", x = 240, y = 270 })' \
  'dispatch hl.dsp.window.move({ window = "address:0xabc", x = 2920, y = 670 })' >"$expected_hyprctl_args"

if ! cmp -s "$HELIOS_TEST_HYPRCTL_ARGS" "$expected_hyprctl_args"; then
  fail "webcam default size adapts to monitor resolution" "$(diff -u "$expected_hyprctl_args" "$HELIOS_TEST_HYPRCTL_ARGS")"
fi
pass "webcam default size adapts to monitor resolution"

: >"$HELIOS_TEST_HYPRCTL_ARGS"
HELIOS_TEST_CLIENT_TITLE="Other Window" "$ROOT/bin/helios-capture-webcam-resize" larger

if [[ -s $HELIOS_TEST_HYPRCTL_ARGS ]]; then
  fail "webcam resize ignores other windows" "$(cat "$HELIOS_TEST_HYPRCTL_ARGS")"
fi
pass "webcam resize ignores other windows"

region_file="$XDG_RUNTIME_DIR/helios-screenrecord-region"

: >"$HELIOS_TEST_HYPRCTL_ARGS"
echo "800x600+100+100" >"$region_file"
"$ROOT/bin/helios-capture-webcam-resize" reset

printf '%s\n' \
  'dispatch hl.dsp.window.resize({ window = "address:0xabc", x = 133, y = 150 })' \
  'dispatch hl.dsp.window.move({ window = "address:0xabc", x = 727, y = 510 })' >"$expected_hyprctl_args"

if ! cmp -s "$HELIOS_TEST_HYPRCTL_ARGS" "$expected_hyprctl_args"; then
  fail "webcam anchors to the recorded region" "$(diff -u "$expected_hyprctl_args" "$HELIOS_TEST_HYPRCTL_ARGS")"
fi
pass "webcam anchors to the recorded region"

printf '%s\n' \
  'dispatch hl.dsp.window.resize({ window = "address:0xabc", x = 178, y = 200 })' \
  'dispatch hl.dsp.window.move({ window = "address:0xabc", x = 2342, y = 460 })' >"$expected_hyprctl_args"

for region in "not-a-region" ""; do
  : >"$HELIOS_TEST_HYPRCTL_ARGS"
  printf '%s' "$region" >"$region_file"
  "$ROOT/bin/helios-capture-webcam-resize" reset

  if ! cmp -s "$HELIOS_TEST_HYPRCTL_ARGS" "$expected_hyprctl_args"; then
    fail "webcam falls back to the monitor for an unusable region" "$(diff -u "$expected_hyprctl_args" "$HELIOS_TEST_HYPRCTL_ARGS")"
  fi
done
pass "webcam falls back to the monitor for an unusable region"

# A region too narrow for presets scaled from its height shrinks the whole
# ladder, so the three sizes stay distinct and each one fits inside the margins
: >"$HELIOS_TEST_HYPRCTL_ARGS"
echo "200x1200+0+0" >"$region_file"
for size in small medium large; do
  "$ROOT/bin/helios-capture-webcam-resize" "$size"
done

printf '%s\n' \
  'dispatch hl.dsp.window.resize({ window = "address:0xabc", x = 64, y = 72 })' \
  'dispatch hl.dsp.window.move({ window = "address:0xabc", x = 96, y = 1088 })' \
  'dispatch hl.dsp.window.resize({ window = "address:0xabc", x = 89, y = 100 })' \
  'dispatch hl.dsp.window.move({ window = "address:0xabc", x = 71, y = 1060 })' \
  'dispatch hl.dsp.window.resize({ window = "address:0xabc", x = 120, y = 135 })' \
  'dispatch hl.dsp.window.move({ window = "address:0xabc", x = 40, y = 1025 })' >"$expected_hyprctl_args"

if ! cmp -s "$HELIOS_TEST_HYPRCTL_ARGS" "$expected_hyprctl_args"; then
  fail "webcam sizes stay distinct and inside a narrow region" "$(diff -u "$expected_hyprctl_args" "$HELIOS_TEST_HYPRCTL_ARGS")"
fi
pass "webcam sizes stay distinct and inside a narrow region"

rm -f "$region_file"

grep -F 'o.bind("SUPER + ALT + code:34", "Make webcam overlay smaller", "helios-capture-webcam-resize smaller")' \
  "$ROOT/default/hypr/bindings/utilities.lua" >/dev/null || fail "webcam smaller hotkey is configured"
grep -F 'o.bind("SUPER + ALT + code:35", "Make webcam overlay larger", "helios-capture-webcam-resize larger")' \
  "$ROOT/default/hypr/bindings/utilities.lua" >/dev/null || fail "webcam larger hotkey is configured"
pass "webcam resize hotkeys are configured"

grep -F -- '--wayland-app-id="WebcamOverlay-$WEBCAM_SIZE"' \
  "$ROOT/bin/helios-capture-screenrecording" >/dev/null || fail "webcam uses a dedicated size-specific app id"

webcam_rules="$ROOT/default/hypr/apps/webcam-overlay.lua"
grep -F 'move = { "(monitor_w-monitor_h*4/25-40)", "(monitor_h-monitor_h*9/50-40)" }' "$webcam_rules" >/dev/null || \
  fail "small webcam starts at its final corner position"
grep -F 'move = { "(monitor_w-monitor_h*2/9-40)", "(monitor_h-monitor_h/4-40)" }' "$webcam_rules" >/dev/null || \
  fail "medium webcam starts at its final corner position"
grep -F 'move = { "(monitor_w-monitor_h*3/10-40)", "(monitor_h-monitor_h*27/80-40)" }' "$webcam_rules" >/dev/null || \
  fail "large webcam starts at its final corner position"
pass "webcam size rules place the initial window in its final corner"

# The stop path reads the recording state file back and uses its contents as a
# path -- ffmpeg writes beside it, `mv` replaces it, `rm -f` deletes its
# preview -- so it has to live in the per-user runtime directory rather than
# under a name in world-writable /tmp that another account can create first.
recording_dir="$tmp_dir/recordings"
mkdir -p "$recording_dir"

cat >"$stub_bin/pgrep" <<'SH'
#!/bin/bash
exit 1
SH

cat >"$stub_bin/helios-hyprland-monitor-focused" <<'SH'
#!/bin/bash
printf 'DP-1\n'
SH

cat >"$stub_bin/gpu-screen-recorder" <<'SH'
#!/bin/bash
for i in "$@"; do
  [[ -n ${take_next:-} ]] && { : >"$i"; break; }
  [[ $i == "-o" ]] && take_next=1
done
sleep 5
SH

cat >"$stub_bin/helios-shell" <<'SH'
#!/bin/bash
exit 0
SH

chmod +x "$stub_bin"/pgrep "$stub_bin"/helios-hyprland-monitor-focused \
  "$stub_bin"/gpu-screen-recorder "$stub_bin"/helios-shell

# Compare that name across the run rather than demanding it be absent: the
# whole point of the finding is that anyone can own it already, and a leftover
# from a pre-fix recording would red-light the fixed script.
tmp_state="/tmp/helios-screenrecord-filename"
tmp_state_before=$(stat -c '%y %s' "$tmp_state" 2>/dev/null || true)

HELIOS_SCREENRECORD_DIR="$recording_dir" \
  "$ROOT/bin/helios-capture-screenrecording" --fullscreen >/dev/null 2>&1

pkill -f "$stub_bin/gpu-screen-recorder" 2>/dev/null || true

[[ $(stat -c '%y %s' "$tmp_state" 2>/dev/null) == "$tmp_state_before" ]] ||
  fail "screen recording keeps no state under a fixed /tmp name"
pass "screen recording keeps no state under a fixed /tmp name"

[[ -s $XDG_RUNTIME_DIR/helios-screenrecord-filename ]] ||
  fail "the recording state file lives in the per-user runtime directory" \
    "$(ls -a "$XDG_RUNTIME_DIR")"
pass "the recording state file lives in the per-user runtime directory"

[[ $(<"$XDG_RUNTIME_DIR/helios-screenrecord-filename") == "$recording_dir"/* ]] ||
  fail "the recording state file names the recording that was started" \
    "$(<"$XDG_RUNTIME_DIR/helios-screenrecord-filename")"
pass "the recording state file names the recording that was started"

# The :-/tmp fallback would reopen the hole this PR closes. A recording
# started without a session runtime dir has to land under the state directory.
state_home="$tmp_dir/state-home"
mkdir -p "$state_home/helios" "$tmp_dir/home-fallback"
chmod 755 "$state_home/helios"
tmp_state_before=$(stat -c '%y %s' "$tmp_state" 2>/dev/null || true)

env -u XDG_RUNTIME_DIR \
  HOME="$tmp_dir/home-fallback" \
  XDG_STATE_HOME="$state_home" \
  HELIOS_SCREENRECORD_DIR="$recording_dir" \
  "$ROOT/bin/helios-capture-screenrecording" --fullscreen >/dev/null 2>&1

pkill -f "$stub_bin/gpu-screen-recorder" 2>/dev/null || true

[[ $(stat -c '%y %s' "$tmp_state" 2>/dev/null) == "$tmp_state_before" ]] ||
  fail "without a runtime dir, screen recording still keeps no state under a fixed /tmp name"
pass "without a runtime dir, screen recording still keeps no state under a fixed /tmp name"

fallback_file="$state_home/helios/helios-screenrecord-filename"
[[ -s $fallback_file ]] ||
  fail "without a runtime dir the recording state file lives in the state directory" \
    "$(ls -la "$state_home/helios" 2>/dev/null || true)"
pass "without a runtime dir the recording state file lives in the state directory"

[[ $(<"$fallback_file") == "$recording_dir"/* ]] ||
  fail "the fallback state file names the recording that was started" \
    "$(<"$fallback_file")"
pass "the fallback state file names the recording that was started"

# The overlay resizer reads the region file the recorder writes, so the two
# have to resolve the same fallback as well as the same runtime dir.
: >"$HELIOS_TEST_HYPRCTL_ARGS"
echo "800x600+100+100" >"$state_home/helios/helios-screenrecord-region"
env -u XDG_RUNTIME_DIR \
  HOME="$tmp_dir/home-fallback" \
  XDG_STATE_HOME="$state_home" \
  "$ROOT/bin/helios-capture-webcam-resize" reset

printf '%s\n' \
  'dispatch hl.dsp.window.resize({ window = "address:0xabc", x = 133, y = 150 })' \
  'dispatch hl.dsp.window.move({ window = "address:0xabc", x = 727, y = 510 })' >"$expected_hyprctl_args"

if ! cmp -s "$HELIOS_TEST_HYPRCTL_ARGS" "$expected_hyprctl_args"; then
  fail "without a runtime dir the webcam anchors to the recorded region" "$(diff -u "$expected_hyprctl_args" "$HELIOS_TEST_HYPRCTL_ARGS")"
fi
pass "without a runtime dir the webcam anchors to the recorded region"

mode=$(stat -c '%a' "$state_home/helios" 2>/dev/null || stat -f '%Lp' "$state_home/helios")
[[ $mode == "700" ]] || fail "fallback directory is private even when it already existed" "mode: $mode"
pass "fallback directory is private even when it already existed"

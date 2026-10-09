# Capture and Sharing

Read this before taking screenshots or screen recordings, extracting text from
the screen, or sharing files with other machines.

## Screenshots

```bash
helios screenshot                            # Select a region, annotate with satty
helios capture screenshot region             # Select a region
helios capture screenshot fullscreen save    # Full screen, straight to disk
```

Capture uses grim and slurp, then opens satty to annotate. The first argument
picks the mode (`smart|region|windows|fullscreen|scroll`); everything except
`fullscreen` starts from a slurp selection. A second argument of `copy` or
`save` sends the screenshot straight to the clipboard or disk. Saved
screenshots land in `~/Pictures/Screenshots` by default (override with
`HELIOS_SCREENSHOT_DIR`).

## Screen Recording

```bash
helios screenrecord --fullscreen             # Start recording the full screen
# ...exercise whatever you want on film...
helios screenrecord --stop-recording         # Stop; prints the saved path
```

Optional flags: `--with-desktop-audio`, `--with-microphone-audio`,
`--with-webcam` (plus `--webcam-device=` and `--webcam-size=`), and
`--resolution=<size>`. Without `--fullscreen` a region picker opens first.
Recordings land in the configured Videos directory (override with
`HELIOS_SCREENRECORD_DIR`). Resize a live webcam overlay with
`helios capture webcam resize <smaller|larger|reset|small|medium|large>`.

If recording fails to start, rerun with `HELIOS_SCREENRECORD_DEBUG=true` to
collect a log at `$XDG_RUNTIME_DIR/helios-screenrecord.log` (or `${XDG_STATE_HOME:-$HOME/.local/state}/helios/helios-screenrecord.log` without a session runtime directory) worth attaching to a bug
report.

## Text Capture (OCR)

```bash
helios capture text    # Select a region; extracted text goes to the clipboard
```

## Sharing Files

```bash
helios share clipboard               # Share the clipboard via LocalSend
helios share file <path...>          # Share files with nearby devices
helios share folder <path>           # Share a folder

helios tailscale send <machine> <file...>    # Taildrop to a tailnet machine
helios tailscale receive [directory]         # Save incoming Taildrop files
```

Shrink large captures before sharing them:

```bash
helios transcode <input> [format] [resolution]   # Re-encode pictures/videos for sharing
```

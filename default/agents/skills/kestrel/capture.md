# Capture and Sharing

Read this before taking screenshots or screen recordings, extracting text from
the screen, or sharing files with other machines.

## Screenshots

```bash
kestrel screenshot                            # Select a region, annotate with satty
kestrel capture screenshot region             # Select a region
kestrel capture screenshot fullscreen save    # Full screen, straight to disk
```

Capture uses grim and slurp, then opens satty to annotate. The first argument
picks the mode (`smart|region|windows|fullscreen|scroll`); everything except
`fullscreen` starts from a slurp selection. A second argument of `copy` or
`save` sends the screenshot straight to the clipboard or disk. Saved
screenshots land in `~/Pictures/Screenshots` by default (override with
`KESTREL_SCREENSHOT_DIR`).

## Screen Recording

```bash
kestrel screenrecord --fullscreen             # Start recording the full screen
# ...exercise whatever you want on film...
kestrel screenrecord --stop-recording         # Stop; prints the saved path
```

Optional flags: `--with-desktop-audio`, `--with-microphone-audio`,
`--with-webcam` (plus `--webcam-device=` and `--webcam-size=`), and
`--resolution=<size>`. Without `--fullscreen` a region picker opens first.
Recordings land in the configured Videos directory (override with
`KESTREL_SCREENRECORD_DIR`). Resize a live webcam overlay with
`kestrel capture webcam resize <smaller|larger|reset|small|medium|large>`.

If recording fails to start, rerun with `KESTREL_SCREENRECORD_DEBUG=true` to
collect a log at `$XDG_RUNTIME_DIR/kestrel-screenrecord.log` (or `${XDG_STATE_HOME:-$HOME/.local/state}/kestrel/kestrel-screenrecord.log` without a session runtime directory) worth attaching to a bug
report.

## Text Capture (OCR)

```bash
kestrel capture text    # Select a region; extracted text goes to the clipboard
```

## Sharing Files

```bash
kestrel share clipboard               # Share the clipboard via LocalSend
kestrel share file <path...>          # Share files with nearby devices
kestrel share folder <path>           # Share a folder

kestrel tailscale send <machine> <file...>    # Taildrop to a tailnet machine
kestrel tailscale receive [directory]         # Save incoming Taildrop files
```

Shrink large captures before sharing them:

```bash
kestrel transcode <input> [format] [resolution]   # Re-encode pictures/videos for sharing
```

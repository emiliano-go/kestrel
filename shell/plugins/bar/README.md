# Kestrel bar

This is the Quickshell implementation of the Kestrel status bar. It is
shipped as a first-party plugin of [`kestrel-shell`](../../README.md), the
long-running shell host. The bar is mounted at startup and lives inside
the shell for its whole session.

- `manifest.json` declares the plugin (`id: kestrel.bar`, `kind: bar`) and points at `Bar.qml` as the entry point.
- `Bar.qml` is Kestrel-owned bar engine code, loaded by the kestrel-shell host. Users should not edit it directly.
- `widgets/` holds simple first-party bar widgets with sibling manifests.
- Feature plugins such as `../panels/audio/`, `../panels/network/`, `../panels/power/`, and `../agents/` provide richer popup bar plugins.
- The bar receives its config from the host shell as a `barConfig` property; the host loads it from `~/.config/kestrel/shell.json` (or `config/kestrel/shell.json` when the user has no file).
- `kestrel bar position` updates only the user shell.json file.

## Customizing

The bar config lives under the `bar:` key of `~/.config/kestrel/shell.json`. Out of the box the shell uses [`config/kestrel/shell.json`](../../../config/kestrel/shell.json). Once you customize anything via the bar gestures, `kestrel bar ...`, or by editing shell.json directly, your file is canonical, there is no deep-merge.

The bar is configured directly on the bar itself: drag empty bar space (or click-and-hold) to move the bar to another screen edge, double-left-click empty center-bar space to toggle transparency, and drag widgets to reorder them. The `kestrel bar position`, `kestrel bar transparent`, `kestrel bar move`, and `kestrel bar set` commands do the same from scripts. Enable or disable widgets with `kestrel plugin enable` and `kestrel plugin disable` (widget ids come from `kestrel plugin list`).

Example `shell.json` (bar subtree only shown):

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "transparent": false,
    "centerAnchor": "kestrel.clock",
    "layout": {
      "left": [
        { "id": "kestrel.menu" },
        { "id": "kestrel.spacer", "size": 12 },
        { "id": "kestrel.workspaces" }
      ],
      "center": [
        { "id": "kestrel.media" },
        { "id": "kestrel.clock", "format": "HH:mm" }
      ],
      "right": [
        { "id": "kestrel.audio" },
        { "id": "kestrel.power" }
      ]
    }
  }
}
```

`centerAnchor` pins one center module to the exact horizontal/vertical center and flanks others around it. Set to an empty string to disable anchoring (the center list is centered as a group).

## Module catalogue

### First-party interactive widgets

| Name | What it does | Interactions |
|---|---|---|
| `kestrel.menu` | Kestrel menu launcher | left = menu · right = terminal |
| `kestrel.workspaces` | Hyprland workspace switcher | left = focus workspace |
| `kestrel.clock` | Date/time label + popup with a month grid, ISO week numbers, and month stepping | left = popup · right = cycle label format · middle = timezone selector |
| `kestrel.media` | MPRIS now-playing, scrolling track + artist, cover-art popup | left = play/pause · middle = next · scroll = prev/next · right = popup |
| `kestrel.indicators` | Manual state indicators | left = indicator action |
| `kestrel.tray` | System tray | hover = reveal drawer · right on chevron = manage |
| `kestrel.weather` | Weather icon + popup with forecast | left = popup · right = full notification |
| `kestrel.microphone` | Mic icon + scroll volume | left = mute toggle · middle = audio panel · scroll = source volume |

| `kestrel.audio` | Volume icon + popup with master slider, output-device picker, per-app mixer | left = popup · right = mute · middle = popup · scroll = volume |
| `kestrel.network` | Wi-Fi/Ethernet icon + popup with Wi-Fi scan, signal, connect, DNS provider selection | left = popup |
| `kestrel.tailscale` | Tailscale status, connection switcher, machine browser, and copy actions | left = popup · right = toggle · middle = refresh |
| `kestrel.agents` | AI coding agent limits with pace, today, last week, and all-time model breakdown | left = panel · right = launch agent · middle = next subscription |
| `kestrel.power` | Battery/AC icon + popup with battery stats, power profiles, and system info | left = popup · right = toggle percentage |
| `kestrel.bluetooth` | Bluetooth icon + popup with device list, connect/disconnect, battery | left = popup · right = toggle radio |
| `kestrel.monitor` | Brightness and laptop display controls | left = popup |

The `kestrel.indicators` widget loads individual bar indicators from `indicators/`. Omit `items` (or set it to an empty array) to show all indicators in the default order, or set `items` to a subset such as `["Dnd", "Reminder", "NightLight"]`. Set `alwaysShow` to `true` to keep inactive indicators visible instead of revealing them only on hover. Multiple `kestrel.indicators` instances are allowed, so different sections can show different subsets.

## Orientation

All widgets work in `top`, `bottom`, `left`, and `right` positions. Popups anchor on the side opposite the bar edge, sliding into the workspace. Vertical bars use 28px width; widgets that show text fall back to compact icon-only forms (e.g. `media` hides its scrolling label).

## Custom user modules

The schema accepts arbitrary module ids that you provide. Set `type` to `command` for shell-driven output or `qml` for a custom QML widget. Both still go under `bar.layout.<section>` in `shell.json`.

Command module:

```json
{
  "version": 1,
  "bar": {
    "layout": {
      "right": [
        { "id": "kestrel.tray" },
        { "id": "vpn", "type": "command", "exec": "~/.config/kestrel/bar/scripts/vpn-status", "interval": 5, "tooltip": "VPN", "onClick": "nm-connection-editor" },
        { "id": "kestrel.audio" }
      ]
    }
  }
}
```

The command may print plain text or Waybar-style JSON, for example:

```json
{"text":"󰌆","tooltip":"Work VPN","class":"active"}
```

QML module:

```json
{
  "version": 1,
  "bar": {
    "layout": {
      "right": [
        { "id": "gpu", "type": "qml" },
        { "id": "kestrel.audio" }
      ]
    }
  }
}
```

Then create `~/.config/kestrel/bar/modules/gpu.qml`. If you want to store it elsewhere, add a `source` path.

Custom QML modules should be an `Item` with `implicitWidth` and `implicitHeight`. They may optionally define these properties, which the bar fills after loading:

```qml
import QtQuick

Item {
  property var bar
  property string moduleName
  property var settings

  implicitWidth: 28
  implicitHeight: bar ? bar.barSize : 26

  Text {
    anchors.centerIn: parent
    text: "GPU"
    color: bar ? bar.foreground : "white"
    font.family: bar ? bar.fontFamily : "monospace"
    font.pixelSize: 12
  }

  MouseArea {
    anchors.fill: parent
    onClicked: if (bar) bar.run("kestrel-launch-or-focus-tui btop")
  }
}
```

## Bar properties available to widgets

Widgets receive `bar` (the shell root), `moduleName` (string), and `settings` (object) injected at load time. The bar exposes:

- `bar.foreground`, `bar.background`, `bar.urgent`, theme colors (live-updated)
- `bar.fontFamily`, current monospace family
- `bar.position`, `"top" | "bottom" | "left" | "right"`
- `bar.vertical`, boolean shortcut
- `bar.barSize`, 26 horizontal / 28 vertical
- `bar.run(command)`, fire-and-forget bash exec (quote arguments with `Util.shellQuote` from `qs.Commons`)
- `bar.showTooltip(target, text)` / `bar.hideTooltip(target)`, shared tooltip popup
- `bar.requestPopout(owner)` / `bar.releasePopout(owner)`, one-popup-at-a-time coordinator

First-party bar widgets are manifest-backed just like third-party widgets.
Simple widgets carry sibling manifests such as `widgets/Workspaces.manifest.json`;
richer popup plugins live in feature directories such as `../panels/audio/`,
`../panels/network/`, and `../agents/`; and feature plugins such as
`kestrel.menu` and `kestrel.media` declare their bar-widget entry points in their own
`manifest.json`. Bar layout ids are namespaced, e.g. `kestrel.audio`,
`kestrel.network`, and `kestrel.clock`.

Third-party widgets ship as separate plugins under `~/.config/kestrel/plugins/<plugin-id>/` with their own `manifest.json` declaring `kinds: ["bar-widget"]` and a `barWidget` entry point. Rescan, enable, and place third-party plugins with `kestrel-shell shell rescanPlugins`, `kestrel plugin enable`, and `kestrel bar move`.

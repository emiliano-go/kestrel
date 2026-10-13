# Kestrel CLI

Kestrel is usually controlled through the hotkeys and the Kestrel menu (`Super + Space`). But you can also control it through the `kestrel` CLI. This is particularly helpful when you're having an AI agent work with you on customization or configuration.

The CLI has access to all the internal tooling that is used both via the menu and otherwise. You can see everything that's available by running `kestrel` in the terminal.

It looks something like this:

```
~ ❯ kestrel
Kestrel command center

Usage:
  kestrel <command> [args...]
  kestrel commands [--all] [--json] [--check]
  kestrel <group> --help
  kestrel <group> <command> --help

Common commands:
  kestrel update              Update Kestrel and system packages
  kestrel theme list          List available themes
  kestrel theme set <name>    Apply a theme
  kestrel font list           List available fonts
  kestrel screenshot          Take a screenshot
  kestrel debug               Print debugging information

Groups:
  agent          AI coding agents, their usage, and subscription accounts
  audio          Audio input and output controls
  bar            Kestrel shell bar layout and settings
  battery        Battery status helpers
  bluetooth      Bluetooth device controls
  branch         Kestrel git branch management
  branding       About and screensaver branding
  brightness     Display and keyboard brightness
  capture        Screenshots and screen recording
  channel        Kestrel release channel management
  clipboard      Clipboard helpers
  cmd            Command and shortcut helpers
  config         System configuration helpers
  debug          Diagnostics and support logs
  ...
```

And you can dive deeper on every group:

```
~ ❯ kestrel capture
Capture commands, Screenshots and screen recording:
  kestrel capture qr                                                                                                                                                                                                       Decode a QR code from a screenshot region
  kestrel capture screenrecording [--fullscreen] [--with-desktop-audio] [--with-microphone-audio] [--with-webcam] [--webcam-device=<device>] [--webcam-size=<small|medium|large>] [--resolution=<size>] [--stop-recording]  Start or stop screen recording
  kestrel capture screenrecording with webcam                                                                                                                                                                              Pick a webcam and start a screen recording with it
  kestrel capture screenshot [smart|region|windows|fullscreen|scroll] [copy|save]                                                                                                                                          Take a screenshot
  kestrel capture text                                                                                                                                                                                                     Extract text from a screenshot region with OCR
  kestrel capture webcam resize <smaller|larger|reset|small|medium|large>                                                                                                                                                  Resize the active webcam recording overlay
```

Every command takes `--help` too, whether you ask a whole group (`kestrel capture --help`) or a single command (`kestrel capture screenshot --help`).

### Opening the menu from the terminal

The Kestrel menu is scriptable as well, which is handy for your own keybindings. `kestrel menu` opens it at the root, and you can jump straight to any point in the tree by naming it: `kestrel menu summon style.theme` goes right to the theme picker, `kestrel menu toggle system` opens the system menu and closes it again if it's already up, and `kestrel menu close` puts it away.

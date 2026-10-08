# HeliOS CLI

HeliOS is usually controlled through the hotkeys and the HeliOS menu (`Super + Space`). But you can also control it through the `helios` CLI. This is particularly helpful when you're having an AI agent work with you on customization or configuration.

The CLI has access to all the internal tooling that is used both via the menu and otherwise. You can see everything that's available by running `helios` in the terminal.

It looks something like this:

```
~ ❯ helios
HeliOS command center

Usage:
  helios <command> [args...]
  helios commands [--all] [--json] [--check]
  helios <group> --help
  helios <group> <command> --help

Common commands:
  helios update              Update HeliOS and system packages
  helios theme list          List available themes
  helios theme set <name>    Apply a theme
  helios font list           List available fonts
  helios screenshot          Take a screenshot
  helios debug               Print debugging information

Groups:
  agent          AI coding agents, their usage, and subscription accounts
  audio          Audio input and output controls
  bar            HeliOS shell bar layout and settings
  battery        Battery status helpers
  bluetooth      Bluetooth device controls
  branch         HeliOS git branch management
  branding       About and screensaver branding
  brightness     Display and keyboard brightness
  capture        Screenshots and screen recording
  channel        HeliOS release channel management
  clipboard      Clipboard helpers
  cmd            Command and shortcut helpers
  config         System configuration helpers
  debug          Diagnostics and support logs
  ...
```

And you can dive deeper on every group:

```
~ ❯ helios capture
Capture commands — Screenshots and screen recording:
  helios capture qr                                                                                                                                                                                                       Decode a QR code from a screenshot region
  helios capture screenrecording [--fullscreen] [--with-desktop-audio] [--with-microphone-audio] [--with-webcam] [--webcam-device=<device>] [--webcam-size=<small|medium|large>] [--resolution=<size>] [--stop-recording]  Start or stop screen recording
  helios capture screenrecording with webcam                                                                                                                                                                              Pick a webcam and start a screen recording with it
  helios capture screenshot [smart|region|windows|fullscreen|scroll] [copy|save]                                                                                                                                          Take a screenshot
  helios capture text                                                                                                                                                                                                     Extract text from a screenshot region with OCR
  helios capture webcam resize <smaller|larger|reset|small|medium|large>                                                                                                                                                  Resize the active webcam recording overlay
```

Every command takes `--help` too, whether you ask a whole group (`helios capture --help`) or a single command (`helios capture screenshot --help`).

### Opening the menu from the terminal

The HeliOS menu is scriptable as well, which is handy for your own keybindings. `helios menu` opens it at the root, and you can jump straight to any point in the tree by naming it: `helios menu summon style.theme` goes right to the theme picker, `helios menu toggle system` opens the system menu and closes it again if it's already up, and `helios menu close` puts it away.

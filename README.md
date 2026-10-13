# Kestrel

Kestrel is a custom Linux distribution built on Arch Linux. It pairs the Hyprland tiling compositor with the Quickshell desktop shell, and it ships a complete, opinionated set of tools you can be productive with the moment it boots. It is maintained by Emiliano Gandini Outeda.

The hard choices are already made: the window manager, the shell, the terminal, the editor, the browser, the themes. You are not handed a pile of packages and a wiki; you are handed a system that someone with taste assembled and keeps sharp. The bet is a simple one: a beautiful system is a motivating system, and productivity tends to follow motivation.

Kestrel is not a beginner's Linux, and it does not pretend to be. It leans terminal-heavy, config-file-forward, and keyboard-driven. If that reads as an invitation rather than a warning, you are in the right place.

## What is in the box

- **Hyprland** for windows and **Quickshell** for the desktop: a top bar, an app launcher, notifications, an on-screen display, a screensaver, and the rest of the shell, all theme-aware and all scriptable.
- A full toolchain for modern work: **Neovim**, Chromium, Obsidian, LibreOffice, Kdenlive, OBS Studio, and a retro Winamp-style music player for good measure.
- The **`kestrel` CLI**: a single entry point (`kestrel <group> <command>`) over the commands in `bin/`, from theming and screenshots to package and hardware helpers.
- **Rolling updates on Arch**, with an automatic Btrfs snapshot before every upgrade and a one-line rollback from the boot menu.
- **Agentic tooling** wired in through `mise`, so the AI coding agents you use are installed, versioned, and on PATH like any other tool.

## Installing

Install Kestrel from the [Kestrel live ISO](https://github.com/emiliano-go/kestrel-iso). The ISO boots straight into a full Kestrel desktop, not a text installer, so you can try the real thing before you commit to it. When you are ready, the "Install Kestrel" entry in the Super + D menu writes the running system to disk by copying it.

That copy is the whole idea: the machine you install is the machine you were just using, byte for byte. There is no second, parallel definition of the system to drift from what you tested, and no package repository to fetch from at install time. Encryption is on by default; the same wizard can install without encryption, or prepare the machine for a different owner and defer the account setup to first boot.

## Updating

Kestrel is a rolling release and tracks Arch directly. Run `pacman -Syu` for the system and an AUR helper such as `yay -Sua` for AUR packages. There is no `kestrel update` command and no channel switching: the system is the Arch base Kestrel was installed from plus whatever Arch and the AUR ship.

A post-transaction hook records a recovery snapshot after every upgrade (`default/snapper/root`, which keeps the two most recent). To roll back, boot a snapshot from Limine and run `kestrel-snapshot restore`.

## Documentation

[`manual/`](manual/) is the end-user manual, and its authoritative source. Start with [Welcome to Kestrel!](manual/01-welcome-to-kestrel.md).

## Repository layout

- `bin/` the `kestrel-*` commands that end up on `PATH`.
- `config/` defaults copied into `~/.config/` for new users.
- `default/` system integration: systemd units, libalpm hooks, Limine, snapper, Plymouth, SDDM, and friends.
- `etc/` the `/etc` drop-ins Kestrel owns outright.
- `install/` the install and finalize scripts the ISO runs against a target.
- `shell/` the Quickshell desktop.
- `themes/` themes.
- `migrations/` in-place fixes applied to existing installs when a default changes in a way a file copy cannot express.
- `manual/`, `test/` as described above.

## The manual

**The Basics**

- [Welcome to Kestrel!](manual/01-welcome-to-kestrel.md)
- [Getting Started](manual/02-getting-started.md)
- [Coming From Windows](manual/03-coming-from-windows.md)
- [Navigation](manual/04-navigation.md)
- [The top bar](manual/05-the-top-bar.md)
- [Themes](manual/06-themes.md)
- [Hotkeys](manual/07-hotkeys.md)
- [Unified Clipboard & History](manual/08-unified-clipboard-history.md)
- [Reminders](manual/09-reminders.md)
- [Notices](manual/10-notices.md)
- [Text Extraction & Dictation](manual/11-text-extraction-dictation.md)
- [Screenshots & Recording](manual/12-screenshots-recording.md)
- [Toggles, idle & screensaver](manual/13-toggles-idle-screensaver.md)
- [Kestrel CLI](manual/14-kestrel-cli.md)

**The Applications**

- [Terminal](manual/15-terminal.md)
- [Neovim](manual/16-neovim.md)
- [AI](manual/17-ai.md)
- [Development Tools](manual/18-development-tools.md)
- [Shell Tools](manual/19-shell-tools.md)
- [Shell Functions](manual/20-shell-functions.md)
- [TUIs](manual/21-tuis.md)
- [GUIs](manual/22-guis.md)
- [Browsers](manual/23-browsers.md)
- [Commercial apps/services](manual/24-commercial-apps-services.md)
- [Web Apps](manual/25-web-apps.md)
- [Gaming](manual/26-gaming.md)
- [Filling out PDFs](manual/27-filling-out-pdfs.md)
- [Windows VM](manual/28-windows-vm.md)
- [Other Packages](manual/29-other-packages.md)

**Configuration**

- [Updates](manual/30-updates.md)
- [Dotfiles](manual/31-dotfiles.md)
- [Shell plugins](manual/32-shell-plugins.md)
- [Monitors](manual/33-monitors.md)
- [Keyboard, Mouse, Trackpad](manual/34-keyboard-mouse-trackpad.md)
- [Networking](manual/35-networking.md)
- [System sleep](manual/36-system-sleep.md)
- [Hardware authentication](manual/37-hardware-authentication.md)
- [Fonts](manual/38-fonts.md)
- [Backgrounds](manual/39-backgrounds.md)
- [Prompt](manual/40-prompt.md)
- [Branding](manual/41-branding.md)
- [Common tweaks](manual/42-common-tweaks.md)
- [Making your own theme](manual/43-making-your-own-theme.md)

**The Rest**

- [Troubleshooting](manual/45-troubleshooting.md)
- [FAQ](manual/46-faq.md)
- [System snapshots](manual/47-system-snapshots.md)
- [Security](manual/48-security.md)
- [Kestrel on...](manual/49-kestrel-on.md)
- [Dual Boot Install](manual/50-dual-boot-install.md)
- [Unattended Installs](manual/51-unattended-installs.md)

## License

Kestrel is released under the MIT License. See [LICENSE](LICENSE).

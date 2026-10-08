---
name: helios
description: >
  REQUIRED for end-user customization of Linux desktop, window manager, or system config.
  Use when editing ~/.config/hypr/, ~/.config/helios/,
  ~/.config/alacritty/, ~/.config/foot/, ~/.config/kitty/, or ~/.config/ghostty/.
  Triggers: Hyprland, window rules, animations, keybindings, monitors, gaps, borders,
  blur, opacity, helios-shell, bar, terminal config, themes, background,
  night light, idle, lock screen, screenshots, reminders, layer rules, workspace
  settings, display config, and user-facing helios commands. Excludes HeliOS
  source development through `helios dev link` workflows.
---

# HeliOS Skill

Manage [HeliOS](https://omarchy.org/) Linux systems - a beautiful, fun, agentic Arch Linux distribution with Hyprland.

This skill is for end-user customization on installed systems.
It is not for contributing to HeliOS source code.

## When This Skill MUST Be Used

**ALWAYS invoke this skill for end-user requests involving ANY of these:**

- Editing ANY file in `~/.config/hypr/` (window rules, animations, keybindings, monitors, etc.)
- Editing `~/.config/helios/shell.json` (status bar layout, widgets)
- Editing terminal configs (alacritty, foot, kitty, ghostty)
- Editing ANY file in `~/.config/helios/`
- Window behavior, animations, opacity, blur, gaps, borders
- Layer rules, workspace settings, display/monitor configuration
- Themes, backgrounds, fonts, appearance changes
- User-facing `helios` commands (`helios theme ...`, `helios refresh ...`, `helios restart ...`, etc.)
- Screenshots, screen recording, reminders, night light, idle behavior, lock screen

**If you're about to edit a config file in ~/.config/ on this system, STOP and use this skill first.**

**Do NOT use this skill for HeliOS development tasks** (editing the HeliOS source tree, creating migrations, or running `helios dev ...` workflows).

## Topic Guides

Deeper instructions for common areas live next to this file. Read the
matching guide before starting:

- [`hyprland.md`](hyprland.md) - keybindings, monitors, window rules, and other Hyprland config
- [`plugins.md`](plugins.md) - the HeliOS shell: bar layout, widgets, plugins, idle behavior
- [`theming.md`](theming.md) - themes, backgrounds, and fonts
- [`hooks.md`](hooks.md) - automation hooks that run on system events
- [`capture.md`](capture.md) - screenshots, screen recordings, OCR text capture, and file sharing
- [`contributing.md`](contributing.md) - reporting HeliOS bugs and submitting fixes upstream

## Critical Safety Rules

For privileged commands, follow the Privilege Escalation rules below: `sudo` when a terminal is available for the password prompt, `pkexec` when it is not. Do not wrap commands that already manage privilege elevation themselves.

**For end-user customization tasks, NEVER modify anything in `/usr/share/helios/`** - but READING is safe and encouraged.

This directory is owned by the helios package. Any local changes will be
overwritten on the next `helios update`.

```
/usr/share/helios/     # READ-ONLY - NEVER EDIT (reading is OK)
├── bin/                    # Command source (packaged binaries are on PATH)
├── config/                 # Default config templates
├── themes/                 # Stock themes
├── default/                # System defaults
├── shell/                  # HeliOS shell source and defaults
├── migrations/             # Update migrations
└── install/                # Installation scripts
```

**Reading `/usr/share/helios/` is SAFE and useful** - do it freely to:
- Understand how helios commands work: `helios theme set --help` or `cat $(which helios-theme-set)`
- See default configs before customizing: `cat "$HELIOS_PATH/config/helios/shell.json"`
- Check stock theme files to copy for customization
- Reference default hyprland settings: `cat /usr/share/helios/default/hypr/*`

**Always use these safe locations instead:**
- `~/.config/` - User configuration (safe to edit)
- `~/.config/helios/themes/<custom-name>/` - Custom themes
- `~/.config/helios/hooks/` - Custom automation hooks

If the request is to develop HeliOS itself, this skill is out of scope. Follow repository development instructions instead of this skill.

## Privilege Escalation

For an interactive script or command run in a visible terminal, use `sudo` for
privileged work. HeliOS may grant passwordless `sudo` access to particular
commands, and the terminal is the appropriate place to request a password
when one is needed.

Use `pkexec` only when the caller cannot interact with a terminal or cannot
enter a password there, such as a command launched by an agent or a graphical
background process. Do not replace `sudo` with `pkexec` merely because a
command changes system state.

## System Architecture

HeliOS is built on:

| Component | Purpose | Config Location |
|-----------|---------|-----------------|
| **Arch Linux** | Base OS | `/etc/`, `~/.config/` |
| **Hyprland** | Wayland compositor/WM | `~/.config/hypr/` |
| **HeliOS shell** | Status bar + notifications (Quickshell) | `~/.config/helios/shell.json` |
| **Launcher/menus** | Quickshell menu | `~/.config/helios/extensions/helios-menu.jsonc` |
| **Alacritty/Foot/Kitty/Ghostty** | Terminals | `~/.config/<terminal>/` |
| **HeliOS OSD** | On-screen display | Quickshell plugin |

## Command Discovery

HeliOS ships a single `helios` CLI that dispatches to all `helios-*` binaries via `helios <group> <action>`. Always prefer this form — it is self-documenting and stable. The underlying `helios-*` binaries still exist on `PATH` and remain safe to read for source.

```bash
# List every documented command and its summary (--all includes hidden commands)
helios commands

# Show the commands inside a group
helios theme --help
helios refresh --help
helios restart --help

# Show help for a specific command (does not execute it)
helios theme set --help

# Machine-readable listing (binary, route, summary, args, aliases)
helios commands --json

# Read a command's source to understand it
cat $(which helios-theme-set)
```

### Command Groups

Run `helios --help` for the full list. The most common groups:

| Group | Purpose | Example |
|-------|---------|---------|
| `helios refresh` | Reset config to defaults (backs up first) | `helios refresh shell` |
| `helios restart` | Restart a service/app | `helios restart shell` |
| `helios toggle` | Toggle feature on/off | `helios toggle nightlight` |
| `helios theme` | Theme management | `helios theme set <name>` |
| `helios bar` | Bar layout and widgets | `helios bar move helios.clock --section right` |
| `helios plugin` | Manage/clone shell plugins | `helios plugin clone helios.clock` |
| `helios hook` | Install automation hooks | `helios hook install theme-set <script>` |
| `helios install` | Install optional software / packages | `helios install docker dbs` |
| `helios launch` | Launch apps | `helios launch browser` |
| `helios capture` | Screenshots and recordings | `helios capture screenshot` |
| `helios reminder` | Desktop notification reminders | `helios reminder 15 "Pickup Jack"` |
| `helios pkg` | Package management | `helios pkg add <pkg>` |
| `helios setup` | Interactive setup wizards | `helios setup security fingerprint` |
| `helios update` | System updates | `helios update` |

## Configuration Locations

Hyprland config lives in `~/.config/hypr/` — see [`hyprland.md`](hyprland.md).
The HeliOS shell (bar, notifications, plugins, idle) is configured in
`~/.config/helios/shell.json` — see [`plugins.md`](plugins.md).

### Terminals

```
~/.config/alacritty/alacritty.toml
~/.config/foot/foot.ini
~/.config/kitty/kitty.conf
~/.config/ghostty/config
```

**Command:** `helios restart terminal`

### Other Configs

| App | Location |
|-----|----------|
| btop | `~/.config/btop/btop.conf` |
| fastfetch | `/etc/fastfetch/config.jsonc` default; `~/.config/fastfetch/config.jsonc` user override |
| lazygit | `~/.config/lazygit/config.yml` |
| starship | `~/.config/starship.toml` |
| git | `~/.config/git/config` |

## Safe Customization Patterns

### Edit User Config Directly

For simple changes, edit files in `~/.config/`:

```bash
# 1. Read current config
cat ~/.config/hypr/bindings.lua

# 2. Backup before changes
cp ~/.config/hypr/bindings.lua ~/.config/hypr/bindings.lua.bak.$(date +%s)

# 3. Make changes with Edit tool

# 4. Apply changes
# - Hyprland: auto-reloads on save, but MUST validate with `hyprctl reload` and `hyprctl configerrors`
# - HeliOS shell: shell.json and user plugin code under ~/.config/helios/plugins/ hot-reload on save
# - Menus/launcher: ~/.config/helios/extensions/helios-menu.jsonc hot-reloads on save
# - Terminals: apply with `helios restart terminal` (reloads running terminals; foot picks changes up in new windows)
```

### Reset to Defaults -- ALWAYS SEEK USER CONFIRMATION BEFORE RUNNING

When customizations go wrong:

```bash
# Reset specific config (creates backup automatically)
helios refresh shell
helios refresh hyprland

# The refresh command:
# 1. Backs up current config with timestamp
# 2. Copies default from $HELIOS_PATH/config/
# 3. Restarts the component where the refresh needs it (e.g. `refresh shell`)
```

## System Commands

```bash
helios update                  # Full system update
helios version                 # Show HeliOS version
helios debug --no-sudo --print # Debug info (ALWAYS use these flags)
helios system lock             # Lock screen
helios system shutdown         # Shutdown
helios system reboot           # Reboot
```

**IMPORTANT:** Always run `helios debug` with `--no-sudo --print` flags to avoid interactive sudo prompts that will hang the terminal.

## Troubleshooting

```bash
# Get debug information (ALWAYS use these flags to avoid interactive prompts)
helios debug --no-sudo --print

# Reset specific config to defaults
helios refresh <app>

# Refresh specific config file
# config-file path is relative to ~/.config/
# eg. `helios refresh config hypr/hyprland.lua` will refresh ~/.config/hypr/hyprland.lua
helios refresh config <config-file>

# Full reinstall of configs (nuclear option)
helios reinstall
```

## Decision Framework

When user requests system changes:

1. **Is it a stock helios command?** Use it directly
2. **Is it a config edit?** Edit in `~/.config/`, never `/usr/share/helios/`
3. **Is it a theme customization?** Follow [`theming.md`](theming.md); create a NEW custom theme directory
4. **Is it automation?** Follow [`hooks.md`](hooks.md); use `helios hook install` and the hook `.d` directories
5. **Is it a package install?** Use `helios pkg add <pkgs...>` (or `helios pkg aur add <pkgs...>` for AUR-only packages)
6. **Is it built-in shell/plugin code?** Follow [`plugins.md`](plugins.md); clone it with `helios plugin clone`, never edit the packaged copy
7. **Unsure if command exists?** Run `helios commands` (or `helios <group> --help` for one group)

### Reminder Requests

When the user asks to set a reminder, use `helios reminder <minutes> [message]` directly. Convert natural language durations to minutes and title-case short reminder labels when appropriate.

```bash
helios reminder 15 "Pickup Jack"
helios reminder 60 "Check laundry"
helios reminder show
helios reminder clear
```

## Out of Scope

This skill intentionally does not cover HeliOS source development. Do not use this skill for:
- Editing files in `/usr/share/helios/` (`bin/`, `config/`, `default/`, `shell/`, `themes/`, `migrations/`, etc.)
- Creating or editing migrations
- Running `helios dev ...` commands

## Example Requests

- "Change my theme to catppuccin" -> `helios theme set catppuccin`
- "Add a keybinding for Super+E to open file manager" -> Check existing bindings first, then use `o.rebind` to replace one or `o.bind` to add one in `~/.config/hypr/bindings.lua`
- "Configure my external monitor" -> Edit `~/.config/hypr/monitors.lua`
- "Make the window gaps smaller" -> Edit `~/.config/hypr/looknfeel.lua`
- "Turn on night light" -> `helios toggle nightlight` (for time-based schedules, edit `~/.config/hypr/hyprsunset.conf` profiles, then `helios restart hyprsunset`)
- "Set a reminder to pickup jack in 15 minutes" -> `helios reminder 15 "Pickup Jack"`
- "Show my reminders" -> `helios reminder show`
- "Clear all reminders" -> `helios reminder clear`
- "Customize the catppuccin theme colors" -> Overlay: put an edited `colors.toml` in `~/.config/helios/themes/catppuccin/`, then re-apply the theme (see `theming.md`)
- "Run a script every time I change themes" -> Install it with `helios hook install theme-set <script>`
- "Change how workspace labels are rendered" -> Clone `helios.workspaces`, which switches the bar to `<username>.workspaces`, then edit the clone
- "Lock after ten minutes" -> Set `idle.lock` to `600` in `~/.config/helios/shell.json`
- "Reset shell/bar to defaults" -> `helios refresh shell`
- "Record my screen" -> `helios screenrecord --fullscreen`, then `helios screenrecord --stop-recording` (see `capture.md`)
- "Report this bug to HeliOS" -> Gather diagnostics and a capture of the problem, then file it (see `contributing.md`)

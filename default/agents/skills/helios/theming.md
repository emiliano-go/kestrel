# Themes, Backgrounds, and Fonts

Read this before changing themes, backgrounds, fonts, or theme colors.

## Theme Commands

```bash
helios theme list              # Show available themes
helios theme current           # Show current theme
helios theme set <name>        # Apply theme ("Tokyo Night" and "tokyo-night" both work)
helios theme bg next           # Cycle background
helios theme install <url>     # Install from git repo
```

## Making a New Theme

1. Create a directory under `~/.config/helios/themes`.
2. See how an existing theme is done via `/usr/share/helios/themes/catppuccin`.
3. Download a matching background (or several) from the internet and put them in `~/.config/helios/themes/<name-of-new-theme>/backgrounds/`.
4. When done with the theme, run `helios theme set "Name of new theme"`.

Additional user backgrounds for any theme (stock or custom) go in
`~/.config/helios/backgrounds/<theme-slug>/`.

## What a Theme Installed From a Repo May Not Contain

A theme the user wrote by hand in `~/.config/helios/themes` is unrestricted, as
are HeliOS's own themes. From a theme cloned by `helios theme install`, HeliOS
drops only what runs code: any `*.lua` (Hyprland requires a theme's
`hyprland.lua` and `gum_env.lua` at login, Neovim loads `neovim.lua` at startup),
the terminal configs `alacritty.toml`, `foot.ini`, `ghostty.conf` and
`kitty.conf` (each names the program the terminal launches), and `vscode.json`
(names a VS Code extension to install). Those are regenerated from `colors.toml`
through `$HELIOS_PATH/default/themed/*.tpl`, and named on stderr.

Everything else a cloned theme ships is kept, including `btop.theme`,
`chromium.theme`, `helix.toml`, `icons.theme`, `keyboard.rgb` and `shell.toml`.
HeliOS tells a cloned theme from the user's own by the `.git` directory a clone
leaves behind.

To change how HeliOS themes an app for every theme, write the template rather
than the theme: `~/.config/helios/themed/<config-name>.tpl` overrides the
built-in one. See `docs/theming.md` in the HeliOS repo.

## Customizing a Stock Theme

Never edit stock themes under `/usr/share/helios/themes/` — changes are lost
on update. Two safe options:

Both write into `~/.config/helios/themes`, where a theme the user wrote is
unrestricted — the list above applies only to a theme cloned from a repo.

**Overlay (preferred for small tweaks):** create a user theme directory with
the SAME slug containing only the files you want to change. When the theme is
applied, the stock theme is copied first and your files win on top:

```bash
mkdir -p ~/.config/helios/themes/catppuccin
cp /usr/share/helios/themes/catppuccin/colors.toml ~/.config/helios/themes/catppuccin/
# Edit the copied colors.toml, then re-apply:
helios theme set catppuccin
```

**Fork:** copy the whole stock theme under a new name for a fully independent
variant:

```bash
cp -r /usr/share/helios/themes/catppuccin ~/.config/helios/themes/catppuccin-custom
# Edit ~/.config/helios/themes/catppuccin-custom/, then:
helios theme set catppuccin-custom
```

## Fonts

```bash
helios font list               # Available fonts
helios font current            # Current font
helios font set <name>         # Change font
```

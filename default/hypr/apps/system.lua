-- Floating windows.
o.window({ tag = "floating-window" }, { float = true })
o.window({ tag = "floating-window" }, { center = true })
o.window({ tag = "floating-window" }, { size = { 875, 600 } })

o.window(
  "(org.kestrel.btop|org.kestrel.terminal|org.kestrel.bash|org.codeberg.dnkl.foot|org.gnome.NautilusPreviewer|org.gnome.Evince|Kestrel|About|TUI.float|imv|mpv)",
  {
    tag = "+floating-window",
  }
)

-- The portal only ever shows dialogs — file pickers, screen shares, permission
-- prompts — so every one of its windows belongs in the floating treatment,
-- whatever the app that asked for it titled it.
o.window("xdg-desktop-portal-gtk", { tag = "+floating-window" })
o.window({
  class = "(sublime_text|DesktopEditors|org.gnome.Nautilus)",
  title = "^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[C|c]hoose.*)",
}, { tag = "+floating-window" })

-- The About fastfetch layout needs more columns than the standard float provides.
-- This size only covers the first launch: kestrel-launch-about measures the
-- rendered content, remembers the size that hugs it, and applies that as its own
-- rule before every later launch.
o.window("org.kestrel.about", { float = true })
o.window("org.kestrel.about", { center = true })
o.window("org.kestrel.about", { size = { 920, 480 } })

o.window("qalculate-qt", { float = true })

-- Fullscreen screensaver.
o.window("org.kestrel.screensaver", { fullscreen = true })
o.window("org.kestrel.screensaver", { float = true })
o.window("org.kestrel.screensaver", { animation = "slide" })
-- The launcher picks each screensaver's workspace. A terminal mapped again as it closes lands out of sight instead,
-- where its fullscreen rule cannot take fullscreen from a window.
o.window("org.kestrel.screensaver", { workspace = "special:screensaver silent" })

-- Popped window rounding.
o.window({ tag = "pop" }, { rounding = 8 })

-- Prevent idle while open.
o.window({ tag = "noidle" }, { idle_inhibit = "always" })

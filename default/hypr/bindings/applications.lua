-- Essential application bindings.
o.bind("SUPER + RETURN", "Terminal", o.launch_terminal())
o.bind("SUPER + SHIFT + RETURN", "Browser", { kestrel = "browser" })
o.bind("SUPER + E", "File manager", { kestrel = "nautilus" })
o.bind("SUPER + SHIFT + F", "File manager", { kestrel = "nautilus" })
o.bind("SUPER + ALT + SHIFT + F", "File manager (cwd)", { kestrel = "nautilus-cwd" })
o.bind("SUPER + B", "Browser", { kestrel = "browser" })
o.bind("SUPER + SHIFT + B", "Browser (private)", { kestrel = "browser --private" })
o.bind("SUPER + SHIFT + ALT + B", "Browser (private)", { kestrel = "browser --private" })
o.bind("SUPER + N", "Editor", { kestrel = "editor" })
o.bind("SUPER + SHIFT + N", "Editor", { kestrel = "editor" })
o.bind("SUPER + T", "Activity", { tui = "btop" })

if o.preinstalled_bindings_enabled() then
  -- Bindings for preinstalled Kestrel applications and TUIs.
  o.bind("SUPER + ALT + RETURN", "Tmux", { kestrel = "terminal-tmux" })
  o.bind("SUPER + SHIFT + G", "Signal", { kestrel = "signal" })
  o.bind("SUPER + SHIFT + O", "Obsidian", { launch = "obsidian", focus = "^obsidian$" })
  o.bind("SUPER + SHIFT + SLASH", "Passwords", { kestrel = "1password" })
end

-- Essential application bindings.
o.bind("SUPER + RETURN", "Terminal", o.launch_terminal())
o.bind("SUPER + SHIFT + RETURN", "Browser", { kestrel = "browser" })
o.bind("SUPER + SHIFT + F", "File manager", { kestrel = "nautilus" })
o.bind("SUPER + ALT + SHIFT + F", "File manager (cwd)", { kestrel = "nautilus-cwd" })
o.bind("SUPER + SHIFT + B", "Browser", { kestrel = "browser" })
o.bind("SUPER + SHIFT + ALT + B", "Browser (private)", { kestrel = "browser --private" })
o.bind("SUPER + SHIFT + N", "Editor", { kestrel = "editor" })

if o.preinstalled_bindings_enabled() then
  -- Bindings for preinstalled Kestrel applications and TUIs.
  o.bind("SUPER + ALT + RETURN", "Tmux", { kestrel = "terminal-tmux" })
  o.bind("SUPER + SHIFT + M", "Music", { launch = "zuno", focus = "^[Zz]uno$" })
  if o.cmd_present("lazydocker") then
    o.bind("SUPER + SHIFT + D", "Docker", { tui = "kestrel-launch-docker-tui" })
  end
  o.bind("SUPER + SHIFT + G", "Signal", { kestrel = "signal" })
  o.bind("SUPER + SHIFT + O", "Obsidian", { launch = "obsidian", focus = "^obsidian$" })
  o.bind("SUPER + SHIFT + SLASH", "Passwords", { kestrel = "1password" })
end

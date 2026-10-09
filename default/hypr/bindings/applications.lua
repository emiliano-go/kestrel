-- Essential application bindings.
o.bind("SUPER + RETURN", "Terminal", o.launch_terminal())
o.bind("SUPER + SHIFT + RETURN", "Browser", { kestrel = "browser" })
o.bind("SUPER + SHIFT + F", "File manager", { kestrel = "nautilus" })
o.bind("SUPER + ALT + SHIFT + F", "File manager (cwd)", { kestrel = "nautilus-cwd" })
o.bind("SUPER + SHIFT + B", "Browser", { kestrel = "browser" })
o.bind("SUPER + SHIFT + ALT + B", "Browser (private)", { kestrel = "browser --private" })
o.bind("SUPER + SHIFT + N", "Editor", { kestrel = "editor" })

if o.preinstalled_bindings_enabled() then
  -- Bindings for preinstalled Kestrel applications, TUIs, and web apps.
  o.bind("SUPER + ALT + RETURN", "Tmux", { kestrel = "terminal-tmux" })
  o.bind("SUPER + SHIFT + M", "Music", { launch = "zuno", focus = "^[Zz]uno$" })
  if o.cmd_present("lazydocker") then
    o.bind("SUPER + SHIFT + D", "Docker", { tui = "kestrel-launch-docker-tui" })
  end
  o.bind("SUPER + SHIFT + G", "Signal", { kestrel = "signal" })
  o.bind("SUPER + SHIFT + O", "Obsidian", { launch = "obsidian", focus = "^obsidian$" })
  o.bind("SUPER + SHIFT + SLASH", "Passwords", { kestrel = "1password" })

  o.bind("SUPER + SHIFT + A", "ChatGPT", { webapp = "https://chatgpt.com" })
  o.bind("SUPER + SHIFT + ALT + A", "Grok", { webapp = "https://grok.com" })
  o.bind("SUPER + SHIFT + C", "Calendar", { webapp = "https://app.hey.com/calendar/weeks/" })
  o.bind("SUPER + SHIFT + E", "Email", { webapp = "https://app.hey.com" })
  o.bind("SUPER + SHIFT + ALT + E", "New email", { webapp = "https://app.hey.com/messages/new?display=standalone&new_window=true" })
  o.bind("SUPER + SHIFT + Y", "YouTube", { webapp = "https://youtube.com/" })
  o.bind("SUPER + SHIFT + ALT + G", "WhatsApp", { webapp = "https://web.whatsapp.com/", focus = true })
  o.bind( "SUPER + SHIFT + CTRL + G", "Google Messages", { webapp = "https://messages.google.com/web/conversations", focus = true })
  o.bind("SUPER + SHIFT + P", "Google Photos", { webapp = "https://photos.google.com/", focus = true })
  o.bind("SUPER + SHIFT + S", "Google Maps", { webapp = "https://maps.google.com/", focus = true })
  o.bind("SUPER + SHIFT + X", "X", { webapp = "https://x.com/" })
  o.bind("SUPER + SHIFT + ALT + X", "X Post", { webapp = "https://x.com/compose/post" })
end

if o.shell_succeeds("helios-default-dictation") then
  o.bind("SUPER + CTRL + X", "Toggle dictation", "helios-dictation toggle")
  o.bind("F9", "Start dictation (push-to-talk)", "helios-dictation start")
  o.bind("F9", "Stop dictation (push-to-talk)", "helios-dictation stop", { release = true })
  -- A modifier's mask changes between its press and release. Match the keysym
  -- independently of that mask; AltGr layouts use a different keysym.
  o.bind("ALT + Alt_R", "Start dictation (push-to-talk)", "helios-dictation start", { ignore_mods = true })
  o.bind("ALT + Alt_R", "Stop dictation (push-to-talk)", "helios-dictation stop", { release = true, ignore_mods = true })
end

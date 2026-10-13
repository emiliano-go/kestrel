-- Send with explicit mods to the focused surface by omitting the window target,
-- so universal shortcuts reach both normal windows and focused layer-shell
-- surfaces such as Kestrel panels. A virtual keyboard (wtype) won't do: the
-- physically held SUPER merges into the injected chord at the seat.
-- The down/up split works around Hyprland send_shortcut sometimes leaving
-- synthetic key state stuck/repeating.
-- https://github.com/hyprwm/Hyprland/discussions/14099
local function send_shortcut_once(mods, key)
  return function()
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))

    hl.timer(function()
      hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
    end, { timeout = 50, type = "oneshot" })
  end
end

o.bind("SUPER + X", "Universal cut", send_shortcut_once("CTRL", "X"))
o.bind("SUPER + V", "Clipboard history", "kestrel-menu-clipboard")
o.bind("SUPER + CTRL + V", "Clipboard manager", { panel = "kestrel.clipboard" })

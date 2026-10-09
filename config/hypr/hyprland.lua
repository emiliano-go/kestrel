-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Kestrel's bootstrap keeps path setup out of this user config.
dofile((os.getenv("KESTREL_PATH") or "/usr/share/kestrel") .. "/default/hypr/bootstrap.lua")

-- Disable all Kestrel default bindings. Add your own in hypr/bindings.lua.
-- kestrel_default_bindings = false
--
-- Or disable only bindings for Kestrel's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- kestrel_preinstalled_bindings = false

-- Load Kestrel defaults.
require("default.hypr.kestrel")

-- Put your personal overrides in these files. They're loaded after Kestrel's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

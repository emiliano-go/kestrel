-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- HeliOS's bootstrap keeps path setup out of this user config.
dofile((os.getenv("HELIOS_PATH") or "/usr/share/helios") .. "/default/hypr/bootstrap.lua")

-- Disable all HeliOS default bindings. Add your own in hypr/bindings.lua.
-- helios_default_bindings = false
--
-- Or disable only bindings for HeliOS's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- helios_preinstalled_bindings = false

-- Load HeliOS defaults.
require("default.hypr.helios")

-- Put your personal overrides in these files. They're loaded after HeliOS's
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

-- Restore workspace layouts saved by helios-hyprland-workspace-layout-toggle.

local paths = require("default.hypr.paths")
local require_all = require("default.hypr.require_all")

local layouts_dir = paths.state_home .. "/helios/workspace-layouts"

require_all.files(layouts_dir, "helios.workspace-layouts", { reload = true })

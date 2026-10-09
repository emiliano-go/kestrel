-- Restore workspace layouts saved by kestrel-hyprland-workspace-layout-toggle.

local paths = require("default.hypr.paths")
local require_all = require("default.hypr.require_all")

local layouts_dir = paths.state_home .. "/kestrel/workspace-layouts"

require_all.files(layouts_dir, "kestrel.workspace-layouts", { reload = true })

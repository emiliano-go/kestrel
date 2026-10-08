require("default.hypr.startup-cursor")

hl.on("hyprland.start", function()
  -- Applications inherit the user's cursor; only the compositor starts blank.
  if helios_startup_cursor_pending then
    hl.env("XCURSOR_PATH", helios_startup_cursor.path)
    hl.env("XCURSOR_THEME", helios_startup_cursor.xcursor)
  end

  -- Slow app launch fix -- set systemd vars before starting session services.
  hl.exec_cmd("systemctl --user import-environment $(env | cut -d'=' -f 1)")
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")

  hl.exec_cmd("helios-launch-shell")
  hl.exec_cmd("helios-provision-first-run")
  hl.exec_cmd("helios-powerprofiles-init")
  hl.exec_cmd(o.launch("helios-hyprland-monitor-watch"))
  hl.exec_cmd(o.launch("udiskie --automount --no-notify --no-tray"))

  -- Run post-boot hooks after startup config has loaded.
  hl.exec_cmd("sleep 2 && helios-hook post-boot")
end)

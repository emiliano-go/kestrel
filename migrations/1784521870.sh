echo "Stop the migration notifier from re-triggering itself in a loop"

# The old kestrel-update-user-notify.path used level-triggered PathExistsGlob,
# which busy-loops the notifier service (or, before r1123, killed the path
# unit with unit-start-limit-hit). Reload the fixed units, revive and restart
# the watcher, and enable the once-per-login notifier.
systemctl --user daemon-reload >/dev/null 2>&1 || true
systemctl --user reset-failed kestrel-update-user-notify.path >/dev/null 2>&1 || true
systemctl --user restart kestrel-update-user-notify.path >/dev/null 2>&1 || true
systemctl --user enable kestrel-update-user-notify.service >/dev/null 2>&1 || true

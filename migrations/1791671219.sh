# Rolling updates: a plain `pacman -Syu` now upgrades directly, and the
# 95-kestrel-snapshot hook records a snapshot after each upgrade.

# Drop the hook that forced `pacman -Syu` through the removed Kestrel updater.
guard=/usr/share/libalpm/hooks/00-kestrel-update-guard.hook
if [[ -e $guard ]]; then
  sudo rm -f "$guard"
fi

# Keep only the two most recent snapshots.
if [[ -f /etc/snapper/configs/root ]]; then
  sudo sed -i -E \
    's/^NUMBER_LIMIT=.*/NUMBER_LIMIT="2"/; s/^NUMBER_LIMIT_IMPORTANT=.*/NUMBER_LIMIT_IMPORTANT="2"/' \
    /etc/snapper/configs/root
fi

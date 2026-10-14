# Configure pacman after package installation completes. Offline target package
# installs use the live ISO's offline pacman.conf until this final restore.
cp -f "$KESTREL_PATH/default/pacman/pacman-${KESTREL_MIRROR:-stable}.conf" /etc/pacman.conf
cp -f "$KESTREL_PATH/default/pacman/mirrorlist-${KESTREL_MIRROR:-stable}" /etc/pacman.d/mirrorlist

# Register and trust the Kestrel package repository.
KESTREL_PATH="$KESTREL_PATH" bash -euo pipefail "$KESTREL_INSTALL/config/kestrel-repo.sh"

# Wait for CUPS to own the file, the way kestrel-settings does, so pacman does
# not turn the override into a .pacnew during ISO package installation.
if [[ -f $KESTREL_PATH/etc-overrides/cups-cups-files.conf && -f /etc/cups/cups-files.conf ]]; then
  install -m 0640 -o root -g cups "$KESTREL_PATH/etc-overrides/cups-cups-files.conf" /etc/cups/cups-files.conf
  rm -f /etc/cups/cups-files.conf.pacnew
fi

source "$KESTREL_INSTALL/hardware/pacman.sh"

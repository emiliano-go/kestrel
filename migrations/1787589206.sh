echo "Require signed packages from the HeliOS repository"

# The [helios] repo predates the HeliOS packaging key, so existing installs
# carry a SigLevel override that also accepts unsigned packages. Packages are
# signed now, so drop the override and let the repo inherit the global
# SigLevel = Required DatabaseOptional like every other repo. Machine-wide and
# self-detecting, so another user's rerun no-ops.
helios_sig_override='SigLevel = Optional TrustAll'

if [[ -f /etc/pacman.conf ]] &&
  sed -n '/^\[helios\]/,/^\[/p' /etc/pacman.conf | grep -qxF "$helios_sig_override"; then
  # Requiring signatures with an untrusted packaging key would fail every
  # helios transaction, including the one that could repair it.
  if helios-pkg-missing helios-keyring ||
    ! sudo pacman-key --list-keys 40DFB630FF42BCFFB047046CF0134EE680CAC571 &>/dev/null; then
    helios-update-keyring
  fi

  sudo sed -i "/^\[helios\]/,/^\[/{/^$helios_sig_override$/d}" /etc/pacman.conf
fi

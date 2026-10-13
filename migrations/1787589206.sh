echo "Require signed packages from the Kestrel repository"

# The [kestrel] repo predates the Kestrel packaging key, so existing installs
# carry a SigLevel override that also accepts unsigned packages. Packages are
# signed now, so drop the override and let the repo inherit the global
# SigLevel = Required DatabaseOptional like every other repo. Machine-wide and
# self-detecting, so another user's rerun no-ops.
kestrel_sig_override='SigLevel = Optional TrustAll'

if [[ -f /etc/pacman.conf ]] &&
  sed -n '/^\[kestrel\]/,/^\[/p' /etc/pacman.conf | grep -qxF "$kestrel_sig_override"; then
  # Requiring signatures with an untrusted packaging key would fail every
  # kestrel transaction, including the one that could repair it.
  if kestrel-pkg-missing kestrel-keyring ||
    ! sudo pacman-key --list-keys F759D6D49B0A395AB922414A5CC3B4C50D37E793 &>/dev/null; then
    kestrel-update-keyring
  fi

  sudo sed -i "/^\[kestrel\]/,/^\[/{/^$kestrel_sig_override$/d}" /etc/pacman.conf
fi

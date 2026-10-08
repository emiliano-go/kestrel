echo "Install the fingerprint resume hook on existing fingerprint setups"

# Existing enrolled machines never rerun setup. Install only missing files
# so administrator changes survive an upgrade.

hook_src="${HELIOS_FPRINTD_RESUME_SRC:-$HELIOS_PATH/default/systemd/system-sleep/fprintd-resume}"
hook_dst="${HELIOS_FPRINTD_RESUME_DST:-/usr/lib/systemd/system-sleep/fprintd-resume}"
stop_timeout_src="${HELIOS_FPRINTD_STOP_TIMEOUT_SRC:-$HELIOS_PATH/default/systemd/system/fprintd.service.d/10-stop-timeout.conf}"
stop_timeout_dst="${HELIOS_FPRINTD_STOP_TIMEOUT_DST:-/etc/systemd/system/fprintd.service.d/10-stop-timeout.conf}"
lock_pam="${HELIOS_LOCK_FINGERPRINT_PAM:-/etc/pam.d/helios-lock-fingerprint}"

[[ -f $lock_pam ]] || exit 0

if [[ -f $hook_src && ! -e $hook_dst ]]; then
  echo "Installing the fprintd resume hook"
  sudo install -Dm755 "$hook_src" "$hook_dst"
fi

if [[ -f $stop_timeout_src && ! -e $stop_timeout_dst ]]; then
  sudo install -Dm644 "$stop_timeout_src" "$stop_timeout_dst"
fi

if [[ -f $stop_timeout_dst ]]; then
  reload_needed=$(systemctl show fprintd.service --property=NeedDaemonReload --value)
  if [[ $reload_needed == "yes" ]]; then
    sudo systemctl daemon-reload
  fi
fi

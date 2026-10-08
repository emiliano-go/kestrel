echo "Install the Dell XPS 13 Panther Lake speaker firmware"

if helios-hw-dell-xps13-dx13260-ptl; then
  source "$HELIOS_PATH/install/hardware/dell-xps13-ptl-speaker-firmware.sh"
  helios-state set reboot-required
fi

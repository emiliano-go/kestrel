echo "Enable Dell XPS 13 sidecar speaker amplifiers"

if helios-hw-dell-xps13-sidecar-amps; then
  source "$HELIOS_PATH/install/hardware/dell-xps13-sidecar-amps.sh"
  helios-state set reboot-required
fi

echo "Apply the NVIDIA video driver fix on hybrid laptops"

if kestrel-hw-nvidia && ! kestrel-hw-nvidia-display; then
  # Hyprland applies env at startup. Reloading the updated defaults cannot
  # clear the old overrides inherited by the compositor and its applications.
  kestrel-state set reboot-required
  echo "Reboot to stop forcing NVIDIA VA-API/GLX drivers on the integrated GPU."
fi

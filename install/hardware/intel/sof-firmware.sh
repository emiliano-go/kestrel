# Install Sound Open Firmware for Intel audio DSPs. The sof-audio-pci-intel-*
# driver family requires this firmware; without it PipeWire exposes only a
# Dummy Output sink.

if kestrel-hw-intel-sof; then
  kestrel-pkg-add sof-firmware
fi

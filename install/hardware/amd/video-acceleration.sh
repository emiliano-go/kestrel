# This installs hardware video acceleration for AMD GPUs

if lspci | grep -iE 'vga|3d|display' | grep -qi 'amd'; then
  # Mesa VA-API driver for Radeon / RDNA (also covers decode on older GCN)
  kestrel-pkg-add libva-mesa-driver
fi

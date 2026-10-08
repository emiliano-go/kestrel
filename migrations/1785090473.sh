echo "Repair fingerprint support left without a libfprint"

# An earlier version of this migration swapped libfprint-git for stock
# libfprint in two steps. A run that failed between them left fprintd with
# no library; finish with the driver the fingerprint setup installs now.
if helios-pkg-present fprintd && helios-pkg-missing libfprint && helios-pkg-missing libfprint-git; then
  helios-pkg-add libfprint-git
fi

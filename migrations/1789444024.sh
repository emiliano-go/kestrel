echo "Install missing headers for the HeliOS or T2 kernel"

# Fresh ISO installs mark earlier migrations complete, so the kernel migration
# cannot repair headers omitted by those installers. Package installation is
# idempotent when another user has already applied this repair.
for kernel in linux-helios linux-t2; do
  if helios-pkg-present "$kernel"; then
    helios-pkg-add "$kernel-headers"
  fi
done

sudo dd status=none of=/etc/kestrel/boot.conf <<EOF
cmdline=$boot_params
EOF

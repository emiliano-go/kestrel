sudo dd status=none of=/etc/helios/boot.conf <<EOF
cmdline=$boot_params
EOF

cat <<EOF | sudo tee /etc/udev/rules.d/99-kestrel.rules >/dev/null
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", RUN+="/usr/bin/kestrel-powerprofiles-set"
EOF

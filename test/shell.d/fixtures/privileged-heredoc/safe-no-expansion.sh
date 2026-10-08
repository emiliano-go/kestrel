cat <<EOF | sudo tee /etc/udev/rules.d/99-helios.rules >/dev/null
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", RUN+="/usr/bin/helios-powerprofiles-set"
EOF

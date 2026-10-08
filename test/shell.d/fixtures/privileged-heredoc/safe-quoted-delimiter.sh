cat <<'EOF' | sudo tee /etc/udev/rules.d/99-helios.rules >/dev/null
SUBSYSTEM=="power_supply", RUN+="/usr/bin/helios-powerprofiles-set $HOME"
EOF

cat <<"XML" | sudo tee /etc/helios/agent.xml >/dev/null
<config path="$HOME/.local/share/helios" />
XML

cat <<'EOF' | sudo tee /etc/udev/rules.d/99-kestrel.rules >/dev/null
SUBSYSTEM=="power_supply", RUN+="/usr/bin/kestrel-powerprofiles-set $HOME"
EOF

cat <<"XML" | sudo tee /etc/kestrel/agent.xml >/dev/null
<config path="$HOME/.local/share/kestrel" />
XML

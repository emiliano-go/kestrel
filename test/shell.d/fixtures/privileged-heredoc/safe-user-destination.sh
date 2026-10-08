mkdir -p ~/.config/helios

cat >~/.config/helios/agent.conf <<EOF
helper=$HOME/.local/share/helios/bin/helios-agent
EOF

cat >"$HOME/.local/bin/helios-shim" <<EOF
exec "$HELIOS_PATH/bin/helios-agent" "$@"
EOF

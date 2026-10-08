mask=$((1 << bits))

cat >/etc/helios/agent.conf <<EOF
helper=$HOME/.local/share/helios/bin/helios-agent
EOF

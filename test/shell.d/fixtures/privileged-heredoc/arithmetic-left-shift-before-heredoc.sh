mask=$((1 << bits))

cat >/etc/kestrel/agent.conf <<EOF
helper=$HOME/.local/share/kestrel/bin/kestrel-agent
EOF

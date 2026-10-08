# A plain redirect into /etc, no sudo: the command re-execs itself as root.
cat >/etc/helios/agent.conf <<EOF
helper=$HOME/.local/share/helios/bin/helios-agent
EOF

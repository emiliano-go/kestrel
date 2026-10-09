# A plain redirect into /etc, no sudo: the command re-execs itself as root.
cat >/etc/kestrel/agent.conf <<EOF
helper=$HOME/.local/share/kestrel/bin/kestrel-agent
EOF

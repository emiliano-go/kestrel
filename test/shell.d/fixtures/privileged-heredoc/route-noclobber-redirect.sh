# `>|` is a plain redirect with noclobber overridden, not a redirect into a pipe.
cat >|/etc/helios/agent.conf <<EOF
helper=$HOME/.local/share/helios/bin/helios-agent
EOF

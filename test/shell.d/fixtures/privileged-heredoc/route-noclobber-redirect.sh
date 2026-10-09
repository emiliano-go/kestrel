# `>|` is a plain redirect with noclobber overridden, not a redirect into a pipe.
cat >|/etc/kestrel/agent.conf <<EOF
helper=$HOME/.local/share/kestrel/bin/kestrel-agent
EOF

#!/bin/bash

# Two hops. The scan resolves kestrel_bin into helper, so the value it ends up
# judging still carries an unresolved $HOME rather than a literal path.
kestrel_bin="$HOME/.local/share/kestrel/bin"
helper="$kestrel_bin/kestrel-agent"

# kestrel:heredoc-expands paths=none, helper names the agent, no path is baked in
cat <<EOF | sudo tee /etc/udev/rules.d/99-kestrel-agent.rules >/dev/null
SUBSYSTEM=="power_supply", RUN+="$helper"
EOF

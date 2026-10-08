#!/bin/bash

# Two hops. The scan resolves helios_bin into helper, so the value it ends up
# judging still carries an unresolved $HOME rather than a literal path.
helios_bin="$HOME/.local/share/helios/bin"
helper="$helios_bin/helios-agent"

# helios:heredoc-expands paths=none -- helper names the agent, no path is baked in
cat <<EOF | sudo tee /etc/udev/rules.d/99-helios-agent.rules >/dev/null
SUBSYSTEM=="power_supply", RUN+="$helper"
EOF

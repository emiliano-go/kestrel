#!/bin/bash

# helios:heredoc-expands paths=none -- review regression fixture
sudo tee /etc/helios/review.conf >/dev/null <<EOF
ExecStart=${target:-$HOME/.local/bin/payload}
EOF

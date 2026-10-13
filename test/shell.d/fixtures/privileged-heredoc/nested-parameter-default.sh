#!/bin/bash

# kestrel:heredoc-expands paths=none, review regression fixture
sudo tee /etc/kestrel/review.conf >/dev/null <<EOF
ExecStart=${target:-$HOME/.local/bin/payload}
EOF

#!/bin/bash

cat <<EOF | \
  sudo tee /etc/kestrel/review.conf
ExecStart=$HOME/.local/bin/payload
EOF

#!/bin/bash

cat <<EOF | \
  sudo tee /etc/helios/review.conf
ExecStart=$HOME/.local/bin/payload
EOF

#!/bin/bash

cat <<EOF >/tmp/helios-review-unit
[Service]
ExecStart=$HOME/.local/bin/payload
EOF
sudo install -m 644 /tmp/helios-review-unit /etc/systemd/system/review.service

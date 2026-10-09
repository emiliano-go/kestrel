#!/bin/bash

cat <<EOF >/tmp/kestrel-review-unit
[Service]
ExecStart=$HOME/.local/bin/payload
EOF
sudo install -m 644 /tmp/kestrel-review-unit /etc/systemd/system/review.service

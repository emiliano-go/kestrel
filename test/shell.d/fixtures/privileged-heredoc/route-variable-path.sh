DROP_IN=/etc/systemd/system/kestrel-agent.service.d/override.conf

cat <<EOF | sudo tee "$DROP_IN" >/dev/null
[Service]
ExecStart=$KESTREL_PATH/bin/kestrel-agent
EOF

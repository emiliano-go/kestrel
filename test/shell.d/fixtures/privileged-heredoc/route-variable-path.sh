DROP_IN=/etc/systemd/system/helios-agent.service.d/override.conf

cat <<EOF | sudo tee "$DROP_IN" >/dev/null
[Service]
ExecStart=$HELIOS_PATH/bin/helios-agent
EOF

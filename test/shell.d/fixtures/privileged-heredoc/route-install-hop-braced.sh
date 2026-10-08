tmp=/tmp/helios-generated
cat >"$tmp" <<EOF
command=$HOME/.local/share/helios/bin/example
EOF
sudo install -m644 "${tmp}" /etc/helios/example.conf

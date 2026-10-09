tmp=/tmp/kestrel-generated
cat >"$tmp" <<EOF
command=$HOME/.local/share/kestrel/bin/example
EOF
sudo install -m644 "${tmp}" /etc/kestrel/example.conf

tmp=/tmp/kestrel-generated
copy=$tmp
cat >"$tmp" <<EOF
command=$HOME/.local/share/kestrel/bin/example
EOF
sudo install -m644 "$copy" /etc/kestrel/example.conf

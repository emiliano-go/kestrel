tmp=/tmp/helios-generated
copy=$tmp
cat >"$tmp" <<EOF
command=$HOME/.local/share/helios/bin/example
EOF
sudo install -m644 "$copy" /etc/helios/example.conf

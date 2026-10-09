mkdir -p ~/.config/kestrel

cat >~/.config/kestrel/agent.conf <<EOF
helper=$HOME/.local/share/kestrel/bin/kestrel-agent
EOF

cat >"$HOME/.local/bin/kestrel-shim" <<EOF
exec "$KESTREL_PATH/bin/kestrel-agent" "$@"
EOF

tmp=$(mktemp)

cat >"$tmp" <<EOF
#!/bin/bash
exec "$HOME/.local/share/helios/bin/helios-agent" "$@"
EOF

sudo install -m 0755 "$tmp" /usr/local/bin/helios-agent-shim

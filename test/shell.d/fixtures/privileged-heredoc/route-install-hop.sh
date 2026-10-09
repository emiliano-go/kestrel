tmp=$(mktemp)

cat >"$tmp" <<EOF
#!/bin/bash
exec "$HOME/.local/share/kestrel/bin/kestrel-agent" "$@"
EOF

sudo install -m 0755 "$tmp" /usr/local/bin/kestrel-agent-shim

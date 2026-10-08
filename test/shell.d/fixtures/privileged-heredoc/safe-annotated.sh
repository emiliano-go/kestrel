servers="1.1.1.1 9.9.9.9"

# helios:heredoc-expands paths=none -- $servers is a validated IP list, not a path
cat <<EOF | sudo tee /etc/helios/dns.conf >/dev/null
servers=$servers
EOF

# helios:heredoc-expands paths=storage -- validated by valid_path and symlink-checked before use
cat <<EOF | sudo tee /var/lib/helios/mounts.conf >/dev/null
source=$storage:/storage
EOF

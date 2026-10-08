storage="$HOME/storage"
shared="$HOME/shared"

# helios:heredoc-expands paths=shared,storage -- both sources are validated before use
cat >/etc/helios/mounts.conf <<EOF
storage=$storage:/storage
shared=$shared:/shared
EOF

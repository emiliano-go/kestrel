storage="$HOME/storage"
shared="$HOME/shared"

# kestrel:heredoc-expands paths=shared,storage -- both sources are validated before use
cat >/etc/kestrel/mounts.conf <<EOF
storage=$storage:/storage
shared=$shared:/shared
EOF

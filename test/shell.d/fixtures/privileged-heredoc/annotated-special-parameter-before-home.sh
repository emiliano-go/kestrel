# kestrel:heredoc-expands paths=none, the positional argument is a scalar
sudo tee /etc/kestrel/example.conf <<EOF
argument=$1
command=$HOME/.local/share/kestrel/bin/example
EOF

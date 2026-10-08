# helios:heredoc-expands paths=none -- the positional argument is a scalar
sudo tee /etc/helios/example.conf <<EOF
argument=$1
command=$HOME/.local/share/helios/bin/example
EOF

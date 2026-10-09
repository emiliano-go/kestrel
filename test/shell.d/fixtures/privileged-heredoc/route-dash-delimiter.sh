if true; then
  cat <<-EOF | sudo tee /etc/kestrel/indented.conf >/dev/null
	helper=$HOME/.local/share/kestrel/bin/kestrel-agent
	EOF
fi

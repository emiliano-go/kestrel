if true; then
  cat <<-EOF | sudo tee /etc/helios/indented.conf >/dev/null
	helper=$HOME/.local/share/helios/bin/helios-agent
	EOF
fi

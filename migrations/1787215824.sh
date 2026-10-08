echo "Install hey (hey-cli) via mise wrapper"

if [[ ! -f $HOME/.local/state/helios/preinstalls-removed ]]; then
  helios-mise-install github:basecamp/hey-cli hey
fi

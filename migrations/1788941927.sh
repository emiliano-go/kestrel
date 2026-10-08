echo "Install basecamp (basecamp-cli) via mise wrapper"

if [[ ! -f $HOME/.local/state/helios/preinstalls-removed ]]; then
  helios-mise-install github:basecamp/basecamp-cli basecamp
fi

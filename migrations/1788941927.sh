echo "Install basecamp (basecamp-cli) via mise wrapper"

if [[ ! -f $HOME/.local/state/kestrel/preinstalls-removed ]]; then
  kestrel-mise-install github:basecamp/basecamp-cli basecamp
fi

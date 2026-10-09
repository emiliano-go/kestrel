echo "Install hey (hey-cli) via mise wrapper"

if [[ ! -f $HOME/.local/state/kestrel/preinstalls-removed ]]; then
  kestrel-mise-install github:basecamp/hey-cli hey
fi

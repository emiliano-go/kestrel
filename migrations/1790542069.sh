echo "Install Hype, the Markdown presentation app"

if [[ ! -f $HOME/.local/state/helios/preinstalls-removed ]]; then
  helios-pkg-add hype
fi

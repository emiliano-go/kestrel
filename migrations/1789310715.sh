echo "Install cf (Cloudflare CLI) via mise wrapper"

if [[ ! -f $HOME/.local/state/helios/preinstalls-removed ]]; then
  helios-mise-install npm:cf cf
fi

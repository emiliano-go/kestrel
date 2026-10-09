echo "Install cf (Cloudflare CLI) via mise wrapper"

if [[ ! -f $HOME/.local/state/kestrel/preinstalls-removed ]]; then
  kestrel-mise-install npm:cf cf
fi

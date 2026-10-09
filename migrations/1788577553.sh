echo "Install Cursor CLI via mise wrapper"

# Cursor's own installer links ~/.local/bin/cursor-agent, so an existing
# command is the user's and stays. The wrapper resolves cursor-agent through
# mise's registry, which lists it from 2026.8.15 on.
if kestrel-cmd-missing cursor-agent && [[ ! -f $HOME/.local/state/kestrel/preinstalls-removed ]]; then
  kestrel-mise-install cursor-agent
fi

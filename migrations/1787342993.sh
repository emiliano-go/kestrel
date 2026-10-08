echo "Install ori (OpenRouter's agent harness) via mise wrapper"

if [[ ! -f $HOME/.local/state/helios/preinstalls-removed ]]; then
  helios-mise-install github:OpenRouterLabs/ori-releases ori
fi

echo "Install ori (OpenRouter's agent harness) via mise wrapper"

if [[ ! -f $HOME/.local/state/kestrel/preinstalls-removed ]]; then
  kestrel-mise-install github:OpenRouterLabs/ori-releases ori
fi

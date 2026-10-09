echo "Install oh-my-pi (omp) via mise wrapper"

if [[ ! -f $HOME/.local/state/kestrel/preinstalls-removed ]]; then
  kestrel-mise-install github:can1357/oh-my-pi omp
fi

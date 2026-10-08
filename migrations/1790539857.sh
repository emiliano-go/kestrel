echo "Install Monologue, the webcam recorder"

if [[ ! -f $HOME/.local/state/helios/preinstalls-removed ]]; then
  helios-pkg-add monologue
fi

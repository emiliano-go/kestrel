echo "Replace the Disk Usage TUI with Disktree"

helios-pkg-add disktree-bin
helios-pkg-drop dua-cli

rm -f "$HOME/.local/share/applications/Disk Usage.desktop"
if [[ -d $HOME/.local/share/applications ]]; then
  update-desktop-database "$HOME/.local/share/applications"
fi

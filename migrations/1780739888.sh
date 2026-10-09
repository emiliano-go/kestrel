echo "Use dua for Disk Usage TUI"

kestrel-pkg-add dua-cli
kestrel-pkg-drop dust

APP_DIR="$HOME/.local/share/applications"
ICON_DIR="$APP_DIR/icons"

if [ -f "$APP_DIR/Disk Usage.desktop" ]; then
  rm "$APP_DIR/Disk Usage.desktop"
  kestrel-tui-install "Disk Usage" "dua i" float "$ICON_DIR/Disk Usage.png"
fi

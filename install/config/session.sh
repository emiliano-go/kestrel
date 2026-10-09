# Install the Kestrel Wayland session entries so SDDM can start Mango.
install -d -m 0755 /usr/share/wayland-sessions
install -m 0644 \
  "$KESTREL_PATH/default/wayland-sessions/mango.desktop" \
  "$KESTREL_PATH/default/wayland-sessions/mango-uwsm.desktop" \
  /usr/share/wayland-sessions/

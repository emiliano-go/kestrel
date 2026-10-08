# Real newlines, not a literal \n: the card renders the body as it arrives, and
# elides past three lines.
helios-notification-send -u critical -g  "Learn Keybindings" \
  $'Super + K for cheatsheet.\nSuper + Space for HeliOS Menu.' \
  --exec helios-menu-keybindings

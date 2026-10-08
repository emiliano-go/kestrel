# Setup user theme folder and seed the default only when no theme exists yet.
mkdir -p ~/.config/helios/themes

if [[ ! -s $HOME/.local/state/helios/current/theme.name ]]; then
  # iso-chroot and provision-owner both run without a live session to notify.
  if [[ ${HELIOS_SETUP_CONTEXT:-runtime} != "runtime" ]]; then
    HELIOS_THEME_HEADLESS=1 helios-theme-set "Tokyo Night"
    rm -f ~/.config/chromium/SingletonLock # otherwise archiso owns the Chromium singleton
  else
    helios-theme-set "Tokyo Night"
  fi
fi
helios-theme-set-pi --activate

mkdir -p ~/.config/btop/themes
ln -snf "$HOME/.local/state/helios/current/theme/btop.theme" ~/.config/btop/themes/current.theme

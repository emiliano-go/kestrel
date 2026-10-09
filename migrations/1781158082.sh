echo "Relink Neovim theme to Kestrel current state"

theme_link="$HOME/.config/nvim/lua/plugins/theme.lua"
legacy_absolute_target="$HOME/.config/kestrel/current/theme/neovim.lua"
legacy_relative_target="../../../kestrel/current/theme/neovim.lua"
legacy_home_target="~/.config/kestrel/current/theme/neovim.lua"
current_relative_target="../../../../.local/state/kestrel/current/theme/neovim.lua"

[[ -L $theme_link ]] || exit 0

target=$(readlink "$theme_link") || exit 0

case "$target" in
  "$legacy_absolute_target"|"$legacy_relative_target"|"$legacy_home_target")
    ln -sfn "$current_relative_target" "$theme_link"
    ;;
esac

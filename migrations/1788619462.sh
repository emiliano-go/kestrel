echo "Hand Hermes Desktop the HeliOS theme as a skin"

# Only the app HeliOS installed under Install > AI follows the theme by itself.
# A Hermes the user set up some other way keeps whatever skin they chose.
helios-pkg-present hermes-desktop || exit 0

# The same hand-over a fresh install does. A Hermes that is not ready or refuses
# the write is reported and done with there; only HeliOS's own failures return.
helios-theme-set-hermes --activate

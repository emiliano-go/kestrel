# Set identification from install inputs
if [[ -n ${HELIOS_USER_NAME//[[:space:]]/} ]]; then
  git config --global user.name "$HELIOS_USER_NAME"
fi

if [[ -n ${HELIOS_USER_EMAIL//[[:space:]]/} ]]; then
  git config --global user.email "$HELIOS_USER_EMAIL"
fi

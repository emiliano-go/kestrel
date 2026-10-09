# Set identification from install inputs
if [[ -n ${KESTREL_USER_NAME//[[:space:]]/} ]]; then
  git config --global user.name "$KESTREL_USER_NAME"
fi

if [[ -n ${KESTREL_USER_EMAIL//[[:space:]]/} ]]; then
  git config --global user.email "$KESTREL_USER_EMAIL"
fi

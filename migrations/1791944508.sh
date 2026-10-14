echo "Enable the Kestrel package repository"

KESTREL_PATH="${KESTREL_PATH:-/usr/share/kestrel}"
repo_script="$KESTREL_PATH/install/config/kestrel-repo.sh"
[[ -f $repo_script ]] || exit 0

# Already registered?
if grep -q '^\[kestrel\]' /etc/pacman.conf && [[ -f /etc/pacman.d/kestrel.gpg ]]; then
  exit 0
fi

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

as_root env KESTREL_PATH="$KESTREL_PATH" bash -euo pipefail "$repo_script"

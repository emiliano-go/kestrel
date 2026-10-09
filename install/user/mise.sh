# Upgrades must not delete the version a running process is executing from:
# mise up would prune the old install dir out from under a live session.
mise settings set upgrade.auto_prune false

kestrel-mise-install codex
kestrel-mise-install claude
kestrel-mise-install crush
kestrel-mise-install antigravity-cli agy
kestrel-mise-install gh
kestrel-mise-install copilot
kestrel-mise-install opencode
kestrel-mise-install npm:playwright playwright
kestrel-mise-install pi
kestrel-mise-install github:can1357/oh-my-pi omp
kestrel-mise-install grok
# Cursor's own installer links the same path, so a re-provision keeps it.
kestrel-cmd-missing cursor-agent && kestrel-mise-install cursor-agent
kestrel-mise-install npm:@kitlangton/ghui ghui
kestrel-mise-install aqua:modem-dev/hunk hunk
kestrel-mise-install github:basecamp/hey-cli hey
kestrel-mise-install github:basecamp/basecamp-cli basecamp
kestrel-mise-install npm:cf cf
kestrel-mise-install github:OpenRouterLabs/ori-releases ori
if kestrel-cmd-missing muse; then
  kestrel-mise-install "http:muse[url=https://api.meta.ai/muse-launcher.sh,bin=muse,version_list_url=https://api.meta.ai/muse-code/channels/muse-stable,version_json_path=.version]" muse
fi

# Build the account dispatchers declared by /etc/mise/conf.d.
mise reshim

# Upgrades must not delete the version a running process is executing from:
# mise up would prune the old install dir out from under a live session.
mise settings set upgrade.auto_prune false

helios-mise-install codex
helios-mise-install claude
helios-mise-install crush
helios-mise-install antigravity-cli agy
helios-mise-install gh
helios-mise-install copilot
helios-mise-install opencode
helios-mise-install npm:playwright playwright
helios-mise-install pi
helios-mise-install github:can1357/oh-my-pi omp
helios-mise-install grok
# Cursor's own installer links the same path, so a re-provision keeps it.
helios-cmd-missing cursor-agent && helios-mise-install cursor-agent
helios-mise-install npm:@kitlangton/ghui ghui
helios-mise-install aqua:modem-dev/hunk hunk
helios-mise-install github:basecamp/hey-cli hey
helios-mise-install github:basecamp/basecamp-cli basecamp
helios-mise-install npm:cf cf
helios-mise-install github:OpenRouterLabs/ori-releases ori
if helios-cmd-missing muse; then
  helios-mise-install "http:muse[url=https://api.meta.ai/muse-launcher.sh,bin=muse,version_list_url=https://api.meta.ai/muse-code/channels/muse-stable,version_json_path=.version]" muse
fi

# Build the account dispatchers declared by /etc/mise/conf.d.
mise reshim

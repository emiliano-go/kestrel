echo "Rename the model usage widget to agents and prime its data files"

# The widget formerly known as helios.model-usage is now helios.agents, and
# it no longer scans providers itself: it displays the records that
# helios-agent-usage-update writes under ~/.local/state/helios/agents/usage/.
# Rename the widget wherever a user's config mentions it — bar layout entries
# keep their settings, a disabled widget stays disabled — then generate the
# records once so the bar doesn't sit empty until the widget's first refresh
# timer, and drop the old scanner's cache directory, which nothing reads
# anymore.

config_file="$HOME/.config/helios/shell.json"

if [[ -s $config_file ]]; then
  tmp=$(mktemp)
  jq '
    def rename:
      if . == "helios.model-usage" then
        "helios.agents"
      elif type == "object" and .id == "helios.model-usage" then
        .id = "helios.agents"
      else
        .
      end;

    (if (.bar.layout? | type) == "object" then
      .bar.layout |= map_values(if type == "array" then map(rename) else . end)
    else . end)
    | (if (.disabledPlugins? | type) == "array" then
      .disabledPlugins |= map(rename)
    else . end)
  ' "$config_file" >"$tmp" && mv "$tmp" "$config_file" || rm -f "$tmp"
fi

rm -rf "$HOME/.cache/helios/model-usage"

helios-agent-usage-update || true

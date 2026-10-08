echo "Relink agent skill symlinks to default/agents/skills/helios"

mkdir -p ~/.agents/skills ~/.claude/skills ~/.codex/skills ~/.pi/agent/skills
ln -sfn "$HELIOS_PATH/default/agents/skills/helios" ~/.agents/skills/helios
ln -sfn "$HELIOS_PATH/default/agents/skills/helios" ~/.claude/skills/helios
ln -sfn "$HELIOS_PATH/default/agents/skills/helios" ~/.codex/skills/helios
ln -sfn "$HELIOS_PATH/default/agents/skills/helios" ~/.pi/agent/skills/helios

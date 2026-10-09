echo "Relink agent skill symlinks to default/agents/skills/kestrel"

mkdir -p ~/.agents/skills ~/.claude/skills ~/.codex/skills ~/.pi/agent/skills
ln -sfn "$KESTREL_PATH/default/agents/skills/kestrel" ~/.agents/skills/kestrel
ln -sfn "$KESTREL_PATH/default/agents/skills/kestrel" ~/.claude/skills/kestrel
ln -sfn "$KESTREL_PATH/default/agents/skills/kestrel" ~/.codex/skills/kestrel
ln -sfn "$KESTREL_PATH/default/agents/skills/kestrel" ~/.pi/agent/skills/kestrel

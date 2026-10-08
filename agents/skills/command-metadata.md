# Command Metadata

Read this before adding or changing commands in `bin/`.

Commands in `bin/` can declare CLI metadata in comments near the top of the
file. `bin/helios` scans the first 80 lines, and tests expect command metadata
to remain valid.

Supported metadata keys:

- `# helios:group=...` - override the command group inferred from the filename
- `# helios:name=...` - override the command name inferred from the filename
- `# helios:summary=...` - short help text
- `# helios:args=...` - usage arguments
- `# helios:examples=...` - examples separated with ` | `
- `# helios:alias=...` / `# helios:aliases=...` - alternate routes
- `# helios:hidden=true` - hide from default command listings
- `# helios:requires-sudo=true` - mark commands that require sudo

Only use `helios:examples` where there are args that need explaining.

Prefer explicit metadata for user-facing commands. Keep routes consistent with
the filename unless there is a deliberate alias or compatibility route.

Example:

```bash
# helios:summary=Take a screenshot
# helios:args=[smart|region|windows|fullscreen] [slurp|copy]
# helios:examples=helios screenshot | helios capture screenshot region
```

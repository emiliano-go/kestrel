# Command Metadata

Read this before adding or changing commands in `bin/`.

Commands in `bin/` can declare CLI metadata in comments near the top of the
file. `bin/kestrel` scans the first 80 lines, and tests expect command metadata
to remain valid.

Supported metadata keys:

- `# kestrel:group=...` - override the command group inferred from the filename
- `# kestrel:name=...` - override the command name inferred from the filename
- `# kestrel:summary=...` - short help text
- `# kestrel:args=...` - usage arguments
- `# kestrel:examples=...` - examples separated with ` | `
- `# kestrel:alias=...` / `# kestrel:aliases=...` - alternate routes
- `# kestrel:hidden=true` - hide from default command listings
- `# kestrel:requires-sudo=true` - mark commands that require sudo

Only use `kestrel:examples` where there are args that need explaining.

Prefer explicit metadata for user-facing commands. Keep routes consistent with
the filename unless there is a deliberate alias or compatibility route.

Example:

```bash
# kestrel:summary=Take a screenshot
# kestrel:args=[smart|region|windows|fullscreen] [slurp|copy]
# kestrel:examples=kestrel screenshot | kestrel capture screenshot region
```

# Brand

`kestrel.svg` is the single source of truth for Kestrel's logo. Edit it here,
then run the generator to refresh every derived asset:

```bash
./brand/generate
```

## What it regenerates

- `logo.svg` (repo root): the same shape in white, for the GitHub README.
- `icon.png`: the repo/app icon.
- `icon.txt`, `logo.txt`: the ASCII art for the About screen / fastfetch and
  the screensaver / installer.
- `default/plymouth/logo.png`, `default/sddm/kestrel/logo.png`,
  `default/plymouth/logos/kestrel.png`: the boot and login logos.
- `default/plymouth/preview-unlock.png`: the default lock-screen preview.
- `themes/*/unlock.png` and `themes/*/preview-unlock.png`: each theme's lock
  logo (the bird in that theme's foreground color) and its preview.

## Requirements

`rsvg-convert` (librsvg), ImageMagick (`magick`), and the repo's own
`bin/kestrel-transcode-ascii` and `bin/kestrel-plymouth-preview`.

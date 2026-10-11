# Updates

Kestrel updates in place from the Arch repositories. Run `pacman -Syu` in a
terminal (and an AUR helper such as `yay -Sua` for AUR packages).

There is no `kestrel update` command and no channel switching: the system is the
Arch ISO Kestrel was installed from plus whatever the Arch and AUR repositories
ship.

## Snapshots

A post-transaction ALPM hook records a recovery snapshot after every upgrade:

```text
/usr/share/libalpm/hooks/95-kestrel-snapshot.hook
/usr/bin/kestrel-snapshot pacman
```

Snapper keeps the two most recent snapshots (`default/snapper/root`). To roll
back, boot a snapshot from Limine and run `kestrel-snapshot restore`.

## Migrations

Migrations (`migrations/*.sh`) reconcile an existing install when shipped
defaults change in a way a file copy can't. They run per user through
`kestrel-migrate`, and `kestrel-migrate-notify` surfaces pending ones at login.

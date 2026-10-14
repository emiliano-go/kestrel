# Portable vault

Kestrel can carry an encrypted folder inside the ISO: a **vault** that stays
read-only on the pendrive and is unlocked with a passphrase. While it is
unlocked you can work in it normally, but everything you change lives in
memory and is thrown away when you lock it, reboot, or pull the drive. The
encrypted container itself is never modified.

This is meant for a portable workstation: keep your dotfiles, keys, or cloned
repositories in the vault, work on them anywhere, and leave no trace on the
machine you borrowed.

## What "fake read-only" means

The vault is a LUKS2 container holding an ext4 filesystem. Unlocking opens a
device-mapper *snapshot* of it whose copy-on-write store is in compressed RAM
(or on a partition, if configured). Reads come from the container; writes go to
the store. Locking discards the store, so the changes disappear and the
container is byte-for-byte unchanged. If you cloned a large repository into the
vault when you built it, a session only stores your edits, not the repository.

Because the store is compressed, an edit of a large text file costs far less
RAM than the file's size. Very large rewrites (build outputs, `git gc`) do cost
their full size, so keep heavy build artifacts and repacking outside the vault.

## Building an ISO with a vault

Put the folder in and set a passphrase:

```
kestrel-iso-make --vault ~/vault-contents
```

`--vault-size 2G` overrides the container size (the default fits the folder).
The passphrase is prompted for; it never appears on the command line. To script
it, point `KESTREL_VAULT_PASS_FILE` at a file containing the passphrase.

## Adding a vault to a finished ISO

```
kestrel-iso-vault add kestrel.iso ~/vault-contents --sign
```

This writes a new ISO (the old one is untouched), embeds the vault at
`/kestrel/vault.img`, and, with `--sign`, re-signs it. The previous signature is
invalid after any change, so always distribute the new one. `kestrel-iso-vault
list kestrel.iso` reports whether an ISO carries a vault.

## Using the vault

- `Super + Shift + V`, or **kestrel vault unlock**, opens the unlock dialog.
- The unlocked vault is mounted at `/run/kestrel/vault` and linked as `~/Vault`.
- **kestrel vault lock** (or rebooting) unmounts it and discards the session.
- `kestrel vault status` prints whether it is locked or unlocked.

The dialog and the command do the same thing; the dialog is just the password
entry, and the passphrase is passed to the command over a pipe so it never
appears in the process list.

## Capacity and configuration

The copy-on-write store defaults to compressed RAM: a hard ceiling of 25% of
memory, with compression letting it hold several times that in text. Edit
`/etc/kestrel/vault.conf`:

- `KESTREL_VAULT_COW_BACKEND` — `zram` (compressed RAM, default) or `disk`.
- `KESTREL_VAULT_COW_FRACTION` — the RAM ceiling for `zram`.
- `KESTREL_VAULT_COW_DISKSIZE_FACTOR` — how much compression buys.
- `KESTREL_VAULT_DISK_COW_PART` — the partition used by `disk` mode, wrapped in
  an ephemeral key so removal or power loss makes it unreadable.

## Notes

- The passphrase is fixed when the ISO is built. It cannot be changed in place,
  because the container is read-only on the media; rebuild the ISO to change it.
- Files in the vault keep the ownership they had when the ISO was built, so a
  vault built from your account's folder is readable by the live user.

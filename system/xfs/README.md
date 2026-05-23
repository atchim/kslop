# xfs

XFS filesystem support, built-in (`=y`) so the kernel can mount an
XFS root partition without help from an initramfs.

- **`CONFIG_XFS_FS=y`** — XFS filesystem.

If you switch to an initramfs-based boot (LUKS, LVM, etc.), this can
become `=m`. See [ADR-0003](../../docs/adr/0003-direct-efi-stub-boot.md)
for the rationale of the current no-initramfs choice.

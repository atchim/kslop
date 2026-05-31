# No initramfs; boot-critical drivers are `=y`

No initramfs is generated or required at boot. Drivers needed before
root mounts — the storage controller (e.g. `BLK_DEV_NVME`) and the root
filesystem driver (e.g. `XFS_FS`) — are built into the kernel (`=y`),
not modules, so GRUB hands the kernel image straight to the running
system with nothing in between. `CONFIG_EFI_STUB=y` is retained only as
a fallback so the image stays directly EFI-bootable; GRUB is the actual
loader (see ADR-0004).

## Considered Options

- **Initramfs-based boot.** Boot-critical drivers as modules; dracut
  or genkernel produces an initramfs that loads them before root
  mount. Rejected: no install in this repo needs the flexibility
  initramfs provides (no LUKS root, no LVM, no separate `/usr`, no
  network root). Initramfs regeneration is an extra moving part that
  can ship broken boots.

## Consequences

- Boot-critical drivers in `hardware/<machine>/config` must be `=y`.
  Today this is `CONFIG_BLK_DEV_NVME=y`. Other machines adjust their
  hardware fragment to match their root-disk controller.
- Root filesystem driver in `system/<fs>/config` must be `=y`. Today
  that's `CONFIG_XFS_FS=y`.
- Non-boot filesystems (`/efi` vfat, USB storage, etc.) can stay `=m`
  — they mount after init starts and module loading works.
- Reversible. Flip the `=y` symbols to `=m`, add an initramfs
  generator (dracut is already installed system-wide), and point the
  bootloader at the resulting `initramfs-*.img`.

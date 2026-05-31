# GRUB as the bootloader, for a fallback boot menu

The machine boots through GRUB (installed as an EFI application at
`\EFI\gentoo\grubx64.efi`), not the kernel's own EFI stub. GRUB's
generated menu lists every kernel in `/boot` — the primary liquorix
build alongside the `gentoo-dist` kernels — so a broken or mismatched
primary kernel can be sidestepped by picking another entry at boot,
with no rescue media.

## Considered Options

- **Direct EFI stub boot** (one kernel registered with the firmware via
  `efibootmgr`). Rejected: a single firmware boot entry has no menu, so
  a bad kernel or a driver/userspace mismatch leaves no in-place
  fallback. The concrete trigger: out-of-tree `nvidia-drivers` is
  rebuilt only for the `gentoo-dist` kernel on a version bump (it
  carries `USE=dist-kernel`), so the liquorix kernel's nvidia module can
  fall out of sync with the global userspace libs — booting a
  `gentoo-dist` entry is the recovery path.

## Consequences

- Installing a kernel ends with `grub-mkconfig -o /boot/grub/grub.cfg`
  so the new entry appears in the menu.
- The kernel command line (e.g. `pci=routeirq`) is supplied by GRUB, not
  embedded in the image — consistent with the hardware README noting
  that quirk "lives in the bootloader, not the kernel config."
- The `gentoo-dist` kernels are kept installed deliberately; the
  fallback they provide is the reason for the menu.

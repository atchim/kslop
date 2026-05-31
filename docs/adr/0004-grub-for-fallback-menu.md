# GRUB as the bootloader, for a fallback boot menu

The machine boots through GRUB (installed as an EFI application at
`\EFI\gentoo\grubx64.efi`), not the kernel's own EFI stub. GRUB's
generated menu lists every kernel in `/boot` — the primary liquorix
build alongside any others (an older lqx build, or a `gentoo-dist`
kernel if one is kept) — so a broken or mismatched primary kernel can be
sidestepped by picking another entry at boot, with no rescue media.

## Considered Options

- **Direct EFI stub boot** (one kernel registered with the firmware via
  `efibootmgr`). Rejected: a single firmware boot entry has no menu, so
  a bad kernel or a driver/userspace mismatch leaves no in-place
  fallback. The concrete trigger: the out-of-tree `nvidia-drivers`
  module must match the global nvidia userspace libraries, and an
  `@world` rebuild can leave the liquorix kernel's module missing or out
  of sync — booting another entry is the recovery path while it is
  rebuilt.

## Consequences

- Installing a kernel ends with `grub-mkconfig -o /boot/grub/grub.cfg`
  so the new entry appears in the menu.
- The kernel command line (e.g. `pci=routeirq`) is supplied by GRUB, not
  embedded in the image — consistent with the hardware README noting
  that quirk "lives in the bootloader, not the kernel config."
- Keeping at least one extra kernel in `/boot` is deliberate; the
  fallback it provides is the reason for the menu.

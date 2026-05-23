# efi-boot

Direct EFI stub boot path. The kernel image becomes a valid EFI
executable that UEFI firmware launches without a separate bootloader.

- **`CONFIG_EFI`** — UEFI firmware interface.
- **`CONFIG_EFI_STUB`** — makes `vmlinuz` directly bootable from UEFI.
- **`CONFIG_EFI_MIXED`** — 32-bit firmware booting a 64-bit kernel.
  Harmless on pure 64-bit; cheap future-proofing.
- **`CONFIG_EFI_PARTITION`** — GPT partition table support.
- **`CONFIG_EFIVAR_FS`** — `/sys/firmware/efi/efivars/` for tools
  like `efibootmgr`.
- **`CONFIG_DRM_SIMPLEDRM`** — drives the firmware-supplied
  framebuffer (sysfb) so early-boot graphics work before the real
  GPU driver loads. Modern DRM-native replacement for the legacy
  `FB_EFI`, which would also require `CONFIG_FB=y`.

See [ADR-0003](../../docs/adr/0003-direct-efi-stub-boot.md) for the
broader no-initramfs decision this fragment is part of.

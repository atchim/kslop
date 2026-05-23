# vfat

VFAT/FAT-32 filesystem support plus the NLS codepages typically
needed when mounting FAT volumes — the EFI System Partition (mounted
late, after init starts) and removable storage (USB sticks, SD cards).

- **`CONFIG_FAT_FS=m`**, **`CONFIG_VFAT_FS=m`** — FAT and VFAT
  drivers. Modules, loaded on demand by udev/mount.
- **`CONFIG_NLS_CODEPAGE_437=m`**, **`CONFIG_NLS_ASCII=m`**,
  **`CONFIG_NLS_UTF8=m`** — codepages referenced by typical FAT mount
  options (`codepage=437,iocharset=ascii`, `utf8=true`, etc.).

These are `=m`, not `=y`. `/efi` mounts after the kernel is up and
modules are loadable.

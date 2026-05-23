# Avell Storm 450 (R7 8745HS)

Mid-2024 Avell laptop.

- **CPU:** AMD Ryzen 7 8745HS (Hawk Point, Zen 4, 8C/16T)
- **dGPU:** NVIDIA RTX 4050 Mobile (Ada Lovelace, 6 GB GDDR6)
- **iGPU:** AMD Radeon 780M (RDNA 3)
- **Chipset / NIC / WiFi / audio:** TODO — capture via `lspci -nn` and
  fill in.

## Quirks

- Disable nouveau (`CONFIG_DRM_NOUVEAU` unset) — Ada Lovelace support is
  effectively absent in nouveau; use proprietary `nvidia-drivers`.
- Suspend/resume reliability depends on `CONFIG_AMD_PMC=y`; bind the
  appropriate `amd_pmf` module if firmware advertises support.
- TODO: confirm wired NIC driver (`r8169` vs out-of-tree `r8125`), WiFi
  driver (likely `mt7921e` if MediaTek MT7922), and audio codec.

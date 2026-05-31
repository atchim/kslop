# Avell Storm 450 (R7 8745HS)

Mid-2024 Avell laptop built on a Clevo NH-series barebones (PCI
subsystem ID `1558:35a1`).

- **CPU:** AMD Ryzen 7 8745HS (Hawk Point / Phoenix2, Zen 4, 8C/16T,
  family 25 model 117)
- **dGPU:** NVIDIA RTX 4050 Mobile (Ada Lovelace, AD107)
- **iGPU:** AMD Radeon 780M (RDNA 3, integrated in 8745HS)
- **Wired NIC:** Realtek RTL8111 series (`r8169` driver)
- **Wireless:** Intel AX210 Wi-Fi 6E (`iwlwifi` + `iwlmvm`)
- **Storage:** Lexar NM760 NVMe SSD (DRAM-less)
- **Audio:** three HDA paths — AMD iGPU HDMI, NVIDIA dGPU HDMI, and
  the internal speakers / mic via AMD ACP 6.3 (SOF)
- **USB:** four AMD XHCI controllers (built-in chipset)
- **Bluetooth:** Intel AX210 BT (USB transport, `8087:0032`)
- **Webcam:** Chicony USB2.0 UVC camera (`04f2:b729`)
- **Touchpad:** integrated Elan controller (`ELAN0415` in ACPI),
  I2C-HID over a Synopsys DesignWare I2C controller (`AMDI0010` in
  ACPI), with its interrupt line routed through the AMD GPIO
  pin-controller (enumerated via ACPI, not PCI)

## Quirks

- **Hybrid graphics.** The dGPU is wired as a discrete PCIe device,
  not a muxed setup. Nouveau cannot drive Ada Lovelace usefully;
  nouveau is explicitly disabled in the fragment, and the
  proprietary `nvidia-drivers` package provides the dGPU stack
  (DKMS or precompiled). Rebuilding it against a kslop kernel has
  Gentoo-specific gotchas (out-of-tree `KBUILD_OUTPUT`, `dist-kernel`
  version skew) — see [`docs/installing-gentoo.md`](../../docs/installing-gentoo.md).
- **No Clevo/Tongfang Kconfig support in 7.0.9.** Fan control and
  hotkeys rely on out-of-tree modules (e.g., `tuxedo-keyboard`,
  `clevo-keyboard`) if installed — no kernel symbol covers them.
- **Suspend/resume** depends on `CONFIG_AMD_PMC=y`. The `amd_pmf`
  module is built so it can bind at runtime when firmware advertises
  the Platform Management Framework.
- **CPU microcode** is embedded in the image. `CONFIG_MICROCODE=y`
  only enables the loader; the kernel still needs a _source_ for the
  patch — normally an early initramfs cpio. With no initramfs
  (ADR-0003), the loader finds nothing and the CPU stays on BIOS
  microcode, leaving AMD errata and mitigations (e.g. Transient
  Scheduler Attacks) unfixed. The fragment instead bakes the Zen 4
  (family `0x19`) blob into `vmlinuz` via
  `CONFIG_EXTRA_FIRMWARE="amd-ucode/microcode_amd_fam19h.bin"`, so it
  applies at the earliest boot stage. Confirm with
  `dmesg | grep microcode` showing an "Updated early to revision" line.
  No separate `MICROCODE_AMD` symbol exists in 7.x.
- **NVIDIA dGPU vs. touchpad IRQ collision.** This system's IO-APICs
  cover only GSI 0–55, so PCI INTx for the NVIDIA card is assigned a
  _virtual_ IRQ from the same global namespace `pinctrl_amd` uses for
  its GPIO-line interrupts. With `CONFIG_PINCTRL_AMD=y`, `amd_gpio`
  claims the touchpad's IRQ (observed: 95) before NVIDIA probes, and
  NVIDIA's pre-flight check fails with "Can't find an IRQ for your
  NVIDIA card!" — taking the HDMI port (wired to the dGPU) down with
  it. The fix is a bootloader-level workaround: add `pci=routeirq` to
  the kernel command line so the kernel recomputes PCI IRQ routing
  late and skips the collision. Not a kslop fragment because it lives
  in the bootloader, not the kernel config.

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
- **Touchpad:** integrated, I2C-HID over AMD MP2 I2C bus
  (enumerated via ACPI, not PCI)

## Quirks

- **Hybrid graphics.** The dGPU is wired as a discrete PCIe device,
  not a muxed setup. Nouveau cannot drive Ada Lovelace usefully;
  nouveau is explicitly disabled in the fragment, and the
  proprietary `nvidia-drivers` package provides the dGPU stack
  (DKMS or precompiled).
- **No Clevo/Tongfang Kconfig support in 7.0.9.** Fan control and
  hotkeys rely on out-of-tree modules (e.g., `tuxedo-keyboard`,
  `clevo-keyboard`) if installed — no kernel symbol covers them.
- **Suspend/resume** depends on `CONFIG_AMD_PMC=y`. The `amd_pmf`
  module is built so it can bind at runtime when firmware advertises
  the Platform Management Framework.
- **Microcode loader** is built in (`CONFIG_MICROCODE=y`); modern
  kernels detect the CPU vendor and load the right ucode source
  automatically — no separate `MICROCODE_AMD` symbol exists in 7.x.

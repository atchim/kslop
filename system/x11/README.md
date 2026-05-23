# x11

X.org baseline kernel symbols. Sufficient for any X11 session running
on top of a DRM/KMS driver (amdgpu, nvidia, ...) plus libinput.

- **`CONFIG_DRM=y`** — Direct Rendering Manager core. Built-in so it's
  always present even before a GPU module loads.
- **`CONFIG_DRM_FBDEV_EMULATION=y`** — fbdev API on top of DRM, so
  legacy userspace (early boot, fbcon) renders through DRM.
- **`CONFIG_FRAMEBUFFER_CONSOLE=y`** — text console on the framebuffer
  (the visible boot/login screen before X starts).
- **`CONFIG_INPUT_EVDEV=y`** — event-device input interface used by
  libinput (and the legacy `evdev` X driver).

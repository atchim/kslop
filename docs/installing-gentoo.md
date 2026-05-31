# Installing a kernel (Gentoo)

The Gentoo path for taking a composed **build** (the `.config` from
`build.sh` — see the [README](../README.md)) through to a booted kernel
on this machine. GRUB is the bootloader ([ADR-0004](adr/0004-grub-for-fallback-menu.md));
no initramfs is used ([ADR-0003](adr/0003-no-initramfs.md)).

Examples below use the liquorix source `linux-7.0.10-pf1`, which compiles
to the kernel release `7.0.10-lqx1`. Substitute your own versions.

## Privilege boundary

**Compile as your normal user; use root only to install.** Gentoo's
handbook has you compile as root, but a buggy build step then runs with
full privileges. `build.sh` already sets up an out-of-tree build (`O=`),
so compilation touches only your cache dir as your user. Root (`doas`) is
needed only for `modules_install`, the `/boot` copy, the NVIDIA rebuild,
and `grub-mkconfig`.

## 1. Compose the build

Run `build.sh` per the README. It writes the `.config` to
`~/.cache/kslop/linux-7.0.10-pf1/.config`.

## 2. Compile (as your user)

```sh
make -C /usr/src/linux-7.0.10-pf1 \
  O=~/.cache/kslop/linux-7.0.10-pf1 -j$(nproc)
```

Note the resulting kernel release name — you need it for the file
suffixes below:

```sh
make -s -C /usr/src/linux-7.0.10-pf1 \
  O=~/.cache/kslop/linux-7.0.10-pf1 kernelrelease
# -> 7.0.10-lqx1
```

## 3. Install (as root)

Modules first:

```sh
doas make -C /usr/src/linux-7.0.10-pf1 \
  O=~/.cache/kslop/linux-7.0.10-pf1 modules_install
```

Then place the image, map, and config **by hand** — not `make install`:

```sh
doas cp ~/.cache/kslop/linux-7.0.10-pf1/arch/x86/boot/bzImage /boot/vmlinuz-7.0.10-lqx1
doas cp ~/.cache/kslop/linux-7.0.10-pf1/System.map            /boot/System.map-7.0.10-lqx1
doas cp ~/.cache/kslop/linux-7.0.10-pf1/.config              /boot/config-7.0.10-lqx1
```

Why not `make install`: on Gentoo it calls `installkernel`, which runs
`dracut` and generates an initramfs. This setup boots without one
(ADR-0003), so the image is copied directly.

## 4. Rebuild the out-of-tree NVIDIA modules

The dGPU stack (`x11-drivers/nvidia-drivers`) is out-of-tree and must be
rebuilt for the new kernel or it won't load. Because the kernel was built
out-of-tree, point the ebuild at the build dir with `KBUILD_OUTPUT`:

```sh
doas env KBUILD_OUTPUT=~/.cache/kslop/linux-7.0.10-pf1 \
  KERNEL_DIR=/usr/src/linux \
  emerge --oneshot @module-rebuild
```

Verify the module's `vermagic` matches the new kernel:

```sh
modinfo -F vermagic /lib/modules/7.0.10-lqx1/video/nvidia.ko
# -> 7.0.10-lqx1 SMP preempt mod_unload
```

### Gotcha: `@world` nvidia rebuilds need `KBUILD_OUTPUT`

`nvidia-drivers` is built `USE=-dist-kernel` — the `dist-kernel`
auto-rebuild only ever targeted the `gentoo-dist` kernel, never the
liquorix one. With it off, the ebuild builds against `/usr/src/linux`
(your eselect symlink → the liquorix source). But kslop builds
out-of-tree, so that tree carries no in-tree `.config`: a plain
`emerge @world` that rebuilds `nvidia-drivers` (a driver version bump,
or `@module-rebuild`) **fails — "kernel not configured"** — because it
has no `KBUILD_OUTPUT` and finds nothing to build against.

Pin it once so automatic rebuilds find the out-of-tree config and target
the liquorix kernel directly:

```sh
# /etc/portage/env/nvidia-kbuild.conf
# Absolute path — root reads this, so no ~ expansion.
KBUILD_OUTPUT="/home/<user>/.cache/kslop/linux-7.0.10-pf1"
```

```sh
# /etc/portage/package.env
x11-drivers/nvidia-drivers nvidia-kbuild.conf
```

The kernel module and the global nvidia userspace libraries share one
version; a mismatch means an NVRM API error and a dead dGPU/HDMI (X keeps
running on the amdgpu iGPU). After any `@world` that rebuilt
`nvidia-drivers`, confirm they agree:

```sh
modinfo -F version /lib/modules/7.0.10-lqx1/video/nvidia.ko   # module side
cat /var/db/pkg/x11-drivers/nvidia-drivers-*/PF               # userspace side
```

If they differ (or the module is missing for the running kernel), rerun
the `KBUILD_OUTPUT` rebuild above. A second GRUB entry — another lqx
build, or a `gentoo-dist` kernel if you keep one — is the boot-time
fallback (ADR-0004).

## 5. Register with GRUB

```sh
doas grub-mkconfig -o /boot/grub/grub.cfg
```

The new entry lands at the top of the menu (the default). The kernel
command line — including `pci=routeirq` (see the
[hardware README](../hardware/avell-storm-450-r7-8745hs/README.md)) —
comes from GRUB, not the image.

## 6. Verify

Reboot, pick the new entry, then:

```sh
uname -r   # -> 7.0.10-lqx1
```

## See

- [README](../README.md) — composing the build.
- [ADR-0003](adr/0003-no-initramfs.md) — why there's no initramfs.
- [ADR-0004](adr/0004-grub-for-fallback-menu.md) — why GRUB.
- [hardware/avell-storm-450-r7-8745hs/README.md](../hardware/avell-storm-450-r7-8745hs/README.md)
  — machine quirks (`pci=routeirq`).

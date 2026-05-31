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

### Gotcha: `nvidia-drivers` version bumps via `@world`

`nvidia-drivers` carries `USE=dist-kernel`, so when `emerge @world`
rebuilds it (a `gentoo-kernel-bin` upgrade, or a driver version bump),
the automatic rebuild targets the **`gentoo-dist`** kernel — _not_ the
liquorix one, and it ignores `KBUILD_OUTPUT`. The userspace libraries are
global, so after a _version_ bump the liquorix kernel is left with a
stale `nvidia.ko` that mismatches them → NVRM API mismatch; the dGPU and
its HDMI port fail (X itself still runs on the amdgpu iGPU).

After any `@world` that touched `nvidia-drivers`, rerun the
`KBUILD_OUTPUT` rebuild above before booting liquorix. To check for a
mismatch first:

```sh
modinfo -F version /lib/modules/7.0.10-lqx1/video/nvidia.ko   # module side
cat /var/db/pkg/x11-drivers/nvidia-drivers-*/PF               # userspace side
```

If they differ, rebuild. If you boot before rebuilding, a `gentoo-dist`
GRUB entry is the fallback (ADR-0004).

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

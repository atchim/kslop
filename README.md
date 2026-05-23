# kslop

Composable kernel configuration fragments. Each fragment is a slice of
`.config` symbols merged onto a kernel source's `make defconfig`
baseline via `scripts/kconfig/merge_config.sh`.

## Layout

- `hardware/<slug>/` — fragments tied to a specific machine's silicon.
- `features/<slug>/` — fragments enabling a userspace capability that
  requires specific `CONFIG_*` symbols.
- `flavors/<slug>/` — fragments scoped to knobs unique to one kernel
  source variant.
- `tunings/<slug>/` — UX-driven kernel preferences (HZ, preemption,
  scheduler granularity) not tied to a machine, userspace tool, or
  kernel source variant.
- `system/<slug>/` — installation, provisioning, or boot-infrastructure
  realities (root filesystem driver, EFI vs legacy boot, distro
  support, display server baseline).

Each fragment dir contains a `README.md` (context, quirks, gotchas) and
a file named `config` (extensionless, vim modeline `ft=conf`).

## Building

```sh
./build.sh /usr/src/linux-7.0.9-pf1 \
  flavors/liquorix/config \
  tunings/interactive-desktop/config \
  system/gentoo-base/config \
  system/efi-boot/config \
  system/xfs/config \
  system/vfat/config \
  system/x11/config \
  hardware/avell-storm-450-r7-8745hs/config \
  features/docker/config
```

`build.sh` runs an **out-of-tree build**: `make O=<outdir> defconfig`
against the kernel source tree, then `merge_config.sh -m -O <outdir>`
with the fragments, then `make O=<outdir> olddefconfig`. The kernel
source tree stays read-only; all artifacts (including `.config`) go
to `<outdir>`. Pass `-o <outdir>` to override; the default is
`${XDG_CACHE_HOME:-~/.cache}/kslop/<ksrc-basename>/`.
`merge_config.sh` prints a "Value of CONFIG_X is redefined" line for
every fragment-vs-baseline override — that's expected, not an error.

## See

- [`CONTEXT.md`](./CONTEXT.md) — language, scope rules, relationships.
- [`docs/adr/`](./docs/adr/) — architectural decisions.

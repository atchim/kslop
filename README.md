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

Each fragment dir contains a `README.md` (context, quirks, gotchas) and
a file named `config` (extensionless, vim modeline `ft=conf`).

## Building

```sh
./build.sh /usr/src/linux-liquorix-6.18 \
  flavors/liquorix/config \
  hardware/avell-storm-450-r7-8745hs/config \
  features/docker/config
```

`build.sh` runs `make defconfig` inside the kernel source tree, then
`merge_config.sh -m .config <fragments...>`, then `make olddefconfig`.
Conflicts in the merge propagate as a non-zero exit. The output
`.config` lives in the kernel source tree, not in this repo.

## See

- [`CONTEXT.md`](./CONTEXT.md) — language, scope rules, relationships.
- [`docs/adr/`](./docs/adr/) — architectural decisions.

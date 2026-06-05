# Docker fragment enables both firewall backends

The `features/docker` fragment enables the legacy iptables (`x_tables`)
symbol family and the nftables (`NF_TABLES` + `NFT_*`) family at once,
even though Docker only programs one backend at runtime. The host picks
the backend in userspace (the `iptables` USE flag / `eselect iptables`,
or `"firewall-backend"` in `daemon.json`); the kernel stays agnostic so
that switch never requires a recompile. The Avell runs `iptables
(legacy)` today but intends to migrate to nftables — enabling both makes
that a userspace-only change.

## Considered Options

- **Legacy iptables only.** Matches today's host backend; smallest
  config. Rejected: the planned nftables migration would then need a
  kernel rebuild, defeating the point of composable fragments.
- **nftables only.** Future-facing, but breaks the host now
  (iptables-legacy can't program nftables tables) and Docker's native
  nftables driver is opt-in and newer (Docker 28+, 2025). Rejected as
  premature.
- **Both (chosen).** A handful of extra `=m` modules; the kernel never
  blocks a backend switch in either direction.

## Consequences

- Seeing both families enabled is intentional — do **not** "clean up"
  the apparently redundant backend; deleting either silently breaks
  Docker networking for hosts using that backend.
- Picking/migrating the backend is out of kslop's scope: it is a
  userspace + host-config change, not a kernel change.
- Do not run two host tools against different backends — legacy
  `x_tables` and nftables rules live in separate kernel tables and won't
  see each other.

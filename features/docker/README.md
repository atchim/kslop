# docker

Kernel symbols required by Docker for container isolation, layered
filesystems, bridge networking, and resource limits. Hardware-agnostic.

## What this enables

- **Namespaces** — UTS, IPC, PID, USER, NET. Container isolation
  primitives.
- **Cgroups v2** — resource accounting and limits. Freezer, devices,
  cpuacct, memory, cpusets. Device access on cgroup v2 is enforced via
  eBPF (`CGROUP_BPF` + `BPF_SYSCALL`), not the removed v1 devices
  controller.
- **Resource limits** — `CFS_BANDWIDTH` (`docker run --cpus`) and
  `BLK_DEV_THROTTLING` (`--device-write-bps` / blkio).
- **OverlayFS** — Docker's default storage driver on Linux (overlay2,
  here on xfs).
- **Bridge + veth + netfilter NAT** — default Docker bridge networking
  and port publishing.

## Firewall backend

Networking symbols are enabled for **both** firewall backends:

- **Legacy iptables (`x_tables`)** — `IP_NF_*` / `IP6_NF_*` filter, mangle,
  raw, nat, masquerade. This is what the host runs today
  (`iptables (legacy)`, `NF_TABLES` off) and what Docker auto-detects.
- **nftables** — `NF_TABLES` + `NFT_*`. `NFT_COMPAT` backs the
  iptables-nft shim (the `iptables` binary translating to nftables);
  the rest back Docker's native nftables firewall driver
  (Docker 28+, opt-in via `daemon.json`).

The kernel supporting both means it never blocks a userspace backend
switch. **Choosing/migrating the backend is a host change, not a kernel
change**, and lives outside kslop:

- _iptables-nft shim (lowest risk, distro default):_ build
  `net-firewall/iptables` with `USE=nftables` and/or
  `eselect iptables set xtables-nft-multi`. Docker keeps calling
  `iptables`; rules land in nftables.
- _Docker native nftables driver:_ set
  `"firewall-backend": "nftables"` in `/etc/docker/daemon.json`.
- _Don't mix backends across tools_ — rules in legacy `x_tables` and
  nftables live in separate kernel tables and won't see each other.

See [`docs/adr/0005-docker-dual-firewall-backend.md`](../../docs/adr/0005-docker-dual-firewall-backend.md).

## Module vs. built-in

The netfilter tables/matches/targets are `=m`: not boot-critical, they
autoload when `dockerd`/`iptables`/`nft` first run (after root is
mounted, so no initramfs). Bool symbols (`CGROUP_BPF`, `BPF_SYSCALL`,
`CFS_BANDWIDTH`, `BLK_DEV_THROTTLING`) are `=y` because they cannot be
modules.

## Out of scope here

- **`net.ipv4.ip_forward`** — a runtime sysctl Docker sets itself at
  daemon start; not a kernel `.config` symbol.
- **AppArmor / SELinux** — the `docker` package is built without those
  USE flags on this host, so no LSM symbols are pulled in.
- **systemd cgroup workarounds** on the Gentoo wiki — irrelevant; this
  host is OpenRC.
- **`NETFILTER_XT_MATCH_IPVS` / the `IP_VS` family** — `check-config.sh`
  grades the `xt_ipvs` match "necessary", but it `depends on IP_VS`, the
  load-balancer stack used only by Swarm / kube-proxy ipvs mode.
  Single-host port publishing uses DNAT/MASQUERADE, not ipvs, so the
  whole stack stays out (matches the chosen scope).

## References

- Gentoo Docker wiki: <https://wiki.gentoo.org/wiki/Docker>
- Moby `check-config.sh`:
  <https://github.com/moby/moby/blob/master/contrib/check-config.sh>
- Docker engine prerequisites:
  <https://docs.docker.com/engine/install/binaries/>

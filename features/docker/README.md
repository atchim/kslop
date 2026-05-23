# docker

Kernel symbols required by Docker for container isolation, layered
filesystems, and bridge networking. Hardware-agnostic.

## What this enables

- **Namespaces** — UTS, IPC, PID, USER, NET. Container isolation
  primitives.
- **Cgroups v2** — resource accounting and limits. Freezer, devices,
  cpuacct, memory, cpusets.
- **OverlayFS** — Docker's default storage driver on Linux.
- **Bridge + veth + netfilter NAT** — default Docker bridge networking
  and port publishing.

## References

- Docker engine prerequisites:
  <https://docs.docker.com/engine/install/binaries/>
- Moby `check-config.sh`:
  <https://github.com/moby/moby/blob/master/contrib/check-config.sh>

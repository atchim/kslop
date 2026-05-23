# gentoo-base

Gentoo Linux distro-support knobs from the in-tree `distro/Kconfig`
menu. Setting `CONFIG_GENTOO_LINUX=y` cascades to the child symbols by
default; each is listed in the fragment to document intent and make
flipping any of them off a one-line edit.

## What gets selected (directly or transitively)

- **`CONFIG_GENTOO_LINUX`** — top-level Gentoo support.
- **`CONFIG_GENTOO_LINUX_UDEV`** — pulls in `DEVTMPFS`, `TMPFS`,
  `UNIX`, `SHMEM`. Needed by eudev/systemd-udevd to populate `/dev`
  and back tmpfs mounts at `/dev/shm`, `/run`, `/sys/fs/cgroup`.
- **`CONFIG_GENTOO_LINUX_PORTAGE`** — pulls in `CGROUPS`,
  `NAMESPACES`, `IPC_NS`, `NET_NS`, `PID_NS`, `SYSVIPC`, `USER_NS`,
  `UTS_NS`. Required by Portage `FEATURES=cgroup`, `ipc-sandbox`,
  `network-sandbox`, `pid-sandbox`.
- **`CONFIG_GENTOO_LINUX_INIT_SCRIPT`** — covers OpenRC, runit,
  sysvinit, and other script-based init systems. The name is
  misleading; this is the right symbol for any non-systemd init.
  Pulls in `BINFMT_SCRIPT`, `EPOLL`, `FILE_LOCKING`, `INOTIFY_USER`,
  `SIGNALFD`, `TIMERFD`.

For systemd installs, add `CONFIG_GENTOO_LINUX_INIT_SYSTEMD=y` (the
two `INIT_*` symbols are not mutually exclusive).

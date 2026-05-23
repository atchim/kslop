# interactive-desktop

Kernel preferences for a snappy desktop: high timer-tick rate and full
preemption. Hardware-agnostic and flavor-agnostic — works on any kernel
that exposes these symbols (vanilla, gentoo-sources, liquorix, ...).

## What this changes

- **`CONFIG_HZ_1000=y`** — 1000 Hz timer tick. Defconfig defaults vary
  (250 or 300 Hz). 1000 Hz gives finer scheduling granularity at a
  small power/throughput cost.
- **`CONFIG_PREEMPT=y`** — full kernel preemption. Pairs with the
  1000 Hz tick for low-latency interactive response.

Note: `CONFIG_PREEMPT=y` conflicts with `CONFIG_PREEMPT_DYNAMIC` (the
boot-time-selectable preemption model). `make olddefconfig` resolves
the choice cleanly — PREEMPT wins, PREEMPT_DYNAMIC is forced off.

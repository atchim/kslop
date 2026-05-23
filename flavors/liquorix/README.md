# liquorix

Damentz's mainline-tracking patched kernel.

- **Upstream:** <https://liquorix.net/>
- **Source:** <https://github.com/damentz/liquorix-package>
- **Gentoo overlay:** `sys-kernel/liquorix-sources`
- **Cadence:** typically within ~2 weeks of upstream mainline.

The flavor fragment captures knobs that exist **only** in the liquorix
source tree. Generic desktop tunings (HZ, preemption) live in
[`tunings/interactive-desktop/`](../../tunings/interactive-desktop/);
those symbols exist in vanilla and `gentoo-sources` too and don't
belong here.

## Notable liquorix-only knobs

- **`CONFIG_ZEN_INTERACTIVE`** — master interactivity tuning. Defaults
  to `y`. When on, flips block-scheduler defaults (BFQ for SQ, Kyber
  for MQ), tweaks the VM subsystem (hugepage reclaim, compaction,
  swap-in readahead), and shrinks EEVDF minimal granularity to 0.4 ms.
- **`CONFIG_SCHED_PDS`** / **`CONFIG_SCHED_BMQ`** — Project C alternate
  root schedulers. Off by default (mainline EEVDF wins). To opt in,
  add one of these to this fragment.

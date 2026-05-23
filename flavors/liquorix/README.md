# liquorix

Damentz's mainline-tracking patched kernel.

- **Upstream:** <https://liquorix.net/>
- **Source:** <https://github.com/damentz/liquorix-package>
- **Cadence:** typically within ~2 weeks of upstream mainline.

The flavor fragment captures knobs unique to liquorix — schedulers and
defaults that don't exist on vanilla or `gentoo-sources`.

## Notable features

- **BORE scheduler** — burst-oriented runqueue extension
  (`CONFIG_SCHED_BORE=y`).
- **1000 Hz tick** — `CONFIG_HZ_1000=y`.
- **Full preemption** — `CONFIG_PREEMPT=y` for desktop responsiveness.

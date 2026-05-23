# kslop

A repository of composable kernel configuration fragments. Fragments are merged
onto a kernel-source-provided baseline (`make defconfig`) to produce a final
`.config` for a specific machine and workload.

## Language

**Fragment**:
A text file in the `merge_config.sh` format (`CONFIG_FOO=y`,
`# CONFIG_BAR is not set`) that the kernel build system can compose into a
`.config`.
_Avoid_: patch, snippet, config

**Hardware fragment**:
A fragment scoped to what is specific to one machine's silicon — drivers, CPU
pstate, GPU module, I/O controllers. Identified by machine model, not by
hardware profile.
_Avoid_: host fragment, device fragment, profile

**Feature fragment**:
A fragment that enables a userspace-driven capability — Docker, KVM, Wine, etc.
— by toggling the kernel symbols that capability requires. Hardware-agnostic.
_Avoid_: recipe

**Tuning fragment**:
A fragment scoped to UX-driven kernel preferences — scheduler granularity, HZ
tick rate, preemption model — that aren't tied to a specific machine, userspace
tool, or kernel source variant.
_Avoid_: preference fragment

**Flavor fragment**:
A fragment scoped to knobs unique to one kernel source variant (liquorix,
gentoo-sources, vanilla).
_Avoid_: variant fragment, tree fragment

**Baseline**:
The `.config` produced by `make defconfig` against a specific kernel source.
Not stored in the repo; fragments are merged onto it at build time.
_Avoid_: default config

**Build**:
The assembled `.config` produced by merging a baseline with a chosen set of
fragments via `merge_config.sh`.
_Avoid_: recipe, target, config

## Relationships

- A **build** = a **baseline** + one **flavor fragment** + zero-or-more
  **tuning fragments** + one **hardware fragment** + zero-or-more
  **feature fragments**
- A **baseline** is determined by which kernel source the **flavor fragment**
  targets
- **Fragments** are orthogonal: any combination is valid as long as no two
  touch the same `CONFIG_*` symbol with conflicting values

## Example dialogue

> **Dev:** "I want Docker on the Avell — do I put `CONFIG_NAMESPACES=y` in the
> hardware fragment?"
>
> **Maintainer:** "No. Namespaces aren't a property of the Avell's silicon.
> They go in `features/docker.config`. The hardware fragment stays scoped to
> what's specific to that machine — AMD pstate driver, NVIDIA module, the right
> NIC driver. The build for that machine then merges the hardware fragment with
> whichever feature fragments you want today."

## Scope: when does a feature fragment deserve to exist?

A **feature fragment** exists iff some userspace capability requires specific
`CONFIG_*` symbols that aren't already in the typical defconfig — _and_ those
symbols are toggle-able as a group.

- Userspace tools that ask nothing of the kernel are not candidates.
  Example: `zsnes` (pure userspace SNES emulator) does not deserve a fragment.
- One-line "needs `CONFIG_X=y`" usually belongs in the hardware fragment or a
  larger feature fragment that subsumes it, not its own file.
- Empty stubs are allowed if they document a completed audit
  (e.g., "RetroArch — defconfig sufficient on x86_64, no symbols required").
  Prefer not creating them.

## Flagged ambiguities

- "patch" was used initially for what we now call a **fragment**. Resolved:
  "patch" in kernel parlance means source patches; this repo contains none —
  only **fragments**.
- "recipe" was used initially for **feature fragments**. Resolved: a recipe
  implies the assembled thing, which is now called a **build**. Each composed
  input is a **fragment**.

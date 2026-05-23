# Flat orthogonal layout with folder-per-fragment

Fragments live under three sibling category directories at the repo root —
`hardware/`, `features/`, `flavors/` — each containing folder-per-slug
entries with a `README.md` and an extensionless `config` fragment. Builds
are assembled by passing fragments explicitly to `merge_config.sh`; no
named-target layer exists.

## Considered Options

- **Flavor as outer directory** (`liquorix/hardware/...`,
  `vanilla/hardware/...`). Rejected: hardware and feature fragments are
  largely flavor-independent, so this duplicates ~95% of content across
  each flavor's subtree.
- **Pure fragments + named targets** (e.g.,
  `targets/avell-liquorix-gaming` declaring a fragment list). Rejected
  for now: targets become valuable when the set of "real" combinations
  is large enough to justify documentation beyond shell history. With
  two machines × two flavors × a handful of features, the build command
  stays short. Targets can be added on top later without rearranging
  fragments.

## Consequences

- Fragments must touch disjoint `CONFIG_*` symbols to compose cleanly.
  Cross-cutting interactions are modeled as explicit combo fragments,
  not implicit dependencies between categories.
- Every fragment carries a sibling `README.md`. Empty stubs are allowed
  when a feature audit concludes no kernel symbols are needed.

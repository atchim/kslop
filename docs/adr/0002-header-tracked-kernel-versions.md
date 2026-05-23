# Header-tracked kernel versions; no version directories

Fragments target the _current_ kernel state and carry a `Verified:`
header listing the (flavor, release, date) tuples they have been built
against. Per-symbol fragility is captured with inline `# since X.Y`
comments on the volatile lines only. The repo holds no version-suffixed
directories or filenames.

## Considered Options

- **Per-version directories** (`6.18/hardware/...`, `6.12/...`).
  Rejected: ossifies into "the old fragments nobody touches" without
  solving the underlying question of which fragment-vs-kernel pairs
  have actually been verified.
- **Version-suffixed filenames** (`hardware/avell.6.18.config`).
  Rejected for the same reason, with less structure.
- **Latest-wins with no annotations.** Rejected: when symbols diverge
  between liquorix (mainline-tracking) and gentoo-sources (LTS), the
  reader needs a hint at the symbol where the divergence lives, not
  just at the fragment level.

## Consequences

- `Verified:` is empirical. Adding a tuple requires actually building
  against that flavor and release.
- `merge_config.sh` warnings about unknown symbols are the source of
  truth for drift; `build.sh` propagates them as non-zero exit.
- The repo is intentionally not a historical archive. Past states live
  in git history.

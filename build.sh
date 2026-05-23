#!/bin/bash

# build — compose a kernel .config from fragments and bake it via olddefconfig.
#
# Usage:
#   build.sh <kernel-src-dir> <fragment>...
#
# Where:
#   <kernel-src-dir>   path to an unpacked kernel source tree
#   <fragment>...      one or more fragment paths (relative or absolute)
#
# Steps:
#   - cd into the kernel source tree
#   - make defconfig (writes baseline .config)
#   - scripts/kconfig/merge_config.sh -m .config <fragments...>
#   - make olddefconfig
#
# Exits non-zero on merge conflicts or unknown-symbol redefinitions.

set -euo pipefail

# Show usage and exit non-zero.
usage() {
  echo 'usage: build.sh <kernel-src-dir> <fragment>...' >&2
  exit 2
}

# Resolve a path to absolute form without requiring realpath(1).
abspath() {
  if [[ $1 == /* ]]; then
    printf '%s\n' "$1"
  else
    printf '%s/%s\n' "$PWD" "$1"
  fi
}

(($# >= 2)) || usage

ksrc=$(abspath "$1")
shift

[[ -d $ksrc ]] || {
  echo "build.sh: kernel src not a directory: $ksrc" >&2
  exit 1
}
merge="$ksrc/scripts/kconfig/merge_config.sh"
[[ -x $merge ]] || {
  echo "build.sh: missing merge_config.sh in $ksrc" >&2
  exit 1
}

fragments=()
for f in "$@"; do
  abs=$(abspath "$f")
  [[ -f $abs ]] || {
    echo "build.sh: fragment not found: $abs" >&2
    exit 1
  }
  fragments+=("$abs")
done

cd "$ksrc"

make defconfig >/dev/null

warn_log=$(mktemp)
trap 'rm -f "$warn_log"' EXIT

"$merge" -m .config "${fragments[@]}" 2>"$warn_log"
cat "$warn_log" >&2

if grep -q 'is redefined' "$warn_log"; then
  echo 'build.sh: merge produced conflicts — see warnings above' >&2
  exit 1
fi

make olddefconfig >/dev/null

echo "build.sh: ok — .config written to $ksrc/.config" >&2

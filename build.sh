#!/bin/bash

# build — compose a kernel .config from fragments into an out-of-tree build dir.
#
# Usage:
#   build.sh [-o <outdir>] <kernel-src-dir> <fragment>...
#
# Where:
#   -o <outdir>        out-of-tree build directory. Created if missing.
#                       Default: ${XDG_CACHE_HOME:-~/.cache}/kslop/<ksrc-basename>/
#   <kernel-src-dir>   path to an unpacked kernel source tree
#   <fragment>...      one or more fragment paths (relative or absolute)
#
# Steps:
#   - make -C <ksrc> O=<outdir> defconfig
#   - merge_config.sh -m -O <outdir> <outdir>/.config <fragments...>
#   - make -C <ksrc> O=<outdir> olddefconfig
#
# merge_config.sh prints "Value of CONFIG_X is redefined" for every
# fragment-vs-baseline change — that's the entire point of fragments,
# so we don't fail on it. Fragment-vs-fragment conflicts surface in
# the same output (a symbol redefined twice across the merge sequence);
# treat the output as a change log to skim, not as errors.

set -euo pipefail

# Show usage and exit non-zero.
usage() {
  echo 'usage: build.sh [-o <outdir>] <kernel-src-dir> <fragment>...' >&2
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

outdir=''
while getopts 'o:h' opt; do
  case $opt in
    o) outdir=$OPTARG ;;
    h | *) usage ;;
  esac
done
shift "$((OPTIND - 1))"

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

if [[ -z $outdir ]]; then
  outdir="${XDG_CACHE_HOME:-$HOME/.cache}/kslop/$(basename "$ksrc")"
fi
outdir=$(abspath "$outdir")
mkdir -p "$outdir"

fragments=()
for f in "$@"; do
  abs=$(abspath "$f")
  [[ -f $abs ]] || {
    echo "build.sh: fragment not found: $abs" >&2
    exit 1
  }
  fragments+=("$abs")
done

# Regenerate baseline each run: build.sh is deterministic given inputs,
# not stateful across invocations.
make -C "$ksrc" O="$outdir" defconfig >/dev/null

# Merge fragments. -m: merge only, no make pass.
"$merge" -m -O "$outdir" "$outdir/.config" "${fragments[@]}"

# Resolve undefined symbols against the tree's Kconfig.
make -C "$ksrc" O="$outdir" olddefconfig >/dev/null

echo "build.sh: ok — .config written to $outdir/.config" >&2
echo "build.sh:   next: make -C $ksrc O=$outdir -j$(nproc)" >&2
echo "build.sh:   then: install per docs/installing-gentoo.md" >&2

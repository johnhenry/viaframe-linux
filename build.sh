#!/usr/bin/env bash
# Build viaframe's vm pane image (a 32-bit x86 Linux for v86, one bzImage with its root file system inside). Reproducible: Buildroot is pinned by version and sha256, the configs are in
# this directory, and the same inputs give the same files. Run on a build machine (legiony, under `flock ~/grand-plan/heavy.lock`), as a normal user, with the host tools of
# `vm-image/shell.sh`. Output: $OUT/viaframe-linux.bzimage, with sizes, hashes and the source offer in $OUT/.
# Usage: vm-image/build.sh [work-dir]   (default ~/vm-image-build)
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
WORK=${1:-$HOME/vm-image-build}
BR_VERSION=2026.02.3
BR_SHA256=65528a544f1e07c2f5ec487beca483bd380a6af8351a45f3649a19a0e8b63de2
mkdir -p "$WORK/dl" "$WORK/out"
cd "$WORK"
if [ ! -f "dl/buildroot-$BR_VERSION.tar.gz" ]; then curl -sSLo "dl/buildroot-$BR_VERSION.tar.gz" "https://buildroot.org/downloads/buildroot-$BR_VERSION.tar.gz"; fi
echo "$BR_SHA256  dl/buildroot-$BR_VERSION.tar.gz" | sha256sum -c -
[ -d "buildroot-$BR_VERSION" ] || tar xf "dl/buildroot-$BR_VERSION.tar.gz"
export BR2_DL_DIR="$WORK/dl"
# Reproducible archives and timestamps.
export SOURCE_DATE_EPOCH=${SOURCE_DATE_EPOCH:-1767225600}
cd "buildroot-$BR_VERSION"
make O="$WORK/build" BR2_EXTERNAL="$HERE/br2-external" viaframe_v86_defconfig
make O="$WORK/build" BR2_EXTERNAL="$HERE/br2-external" -j"${JOBS:-8}"
cp "$WORK/build/images/bzImage" "$WORK/out/viaframe-linux.bzimage"
cd "$WORK/out"
sha256sum viaframe-linux.bzimage | tee SHA256SUMS
ls -l viaframe-linux.bzimage
xz -9e -k -c viaframe-linux.bzimage | wc -c | sed 's/^/xz size (not used: a bzImage is already compressed): /'
# The corresponding source for every package in the image (the GPL offer, vm-image/NOTICE.md): Buildroot's legal-info (the target packages' pinned source archives with their patches, the licence texts, the manifest and the
# Buildroot configuration), the Buildroot release it was built with, and this directory's own files, in one archive that is published next to the image.
make -C "$WORK/buildroot-$BR_VERSION" O="$WORK/build" BR2_EXTERNAL="$HERE/br2-external" legal-info >/dev/null
L="$WORK/build/legal-info"
SRC="$WORK/src-bundle"
rm -rf "$SRC" && mkdir -p "$SRC/viaframe-linux-sources"
cp -r "$L/sources" "$L/licenses" "$L/manifest.csv" "$L/buildroot.config" "$L/legal-info.sha256" "$L/README" "$SRC/viaframe-linux-sources/"
# The copied config names this machine's build folder (BR2_EXTERNAL and BR2_DEFCONFIG are absolute paths): publish them relative to the archive's
# vm-image/ folder instead, so the public archive carries no local path, and keep legal-info.sha256's entry for the config right.
CFG="$SRC/viaframe-linux-sources/buildroot.config"
sed -i "s#$HERE/#vm-image/#g" "$CFG"
( cd "$SRC/viaframe-linux-sources" && sed -i "/ buildroot.config\$/d" legal-info.sha256 && sha256sum buildroot.config >> legal-info.sha256 )
cp "$WORK/dl/buildroot-$BR_VERSION.tar.gz" "$SRC/viaframe-linux-sources/"
cp -r "$HERE" "$SRC/viaframe-linux-sources/vm-image"
tar --sort=name --owner=0 --group=0 --numeric-owner --mtime="@$SOURCE_DATE_EPOCH" -C "$SRC" -cf - viaframe-linux-sources | gzip -n -9 > "$WORK/out/viaframe-linux-sources.tar.gz"
cp "$L/manifest.csv" "$WORK/out/viaframe-linux-manifest.csv"
( cd "$WORK/out" && sha256sum viaframe-linux.bzimage viaframe-linux-sources.tar.gz | tee SHA256SUMS )
ls -l "$WORK/out"

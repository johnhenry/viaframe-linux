#!/usr/bin/env bash
# Regenerate board/viaframe/linux.config from linux.fragment (run after changing the fragment or the kernel version): tinyconfig + fragment, resolved by olddefconfig.
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
WORK=${1:-$HOME/vm-image-build}
BR=$WORK/buildroot-2026.02.3
BOARD=$HERE/br2-external/board/viaframe
cd "$BR"
[ -s "$BOARD/linux.config" ] || : > "$BOARD/linux.config"
make O="$WORK/build" BR2_EXTERNAL="$HERE/br2-external" viaframe_v86_defconfig
make O="$WORK/build" BR2_EXTERNAL="$HERE/br2-external" linux-extract
K=$(ls -d "$WORK"/build/build/linux-[0-9]* | head -1)
cd "$K"
make ARCH=i386 tinyconfig
KCONFIG_CONFIG=.config scripts/kconfig/merge_config.sh -m .config "$BOARD/linux.fragment" >/dev/null
make ARCH=i386 olddefconfig
cp .config "$BOARD/linux.config"
echo "kernel $(make -s kernelversion): $(grep -c '=y' .config) options on"
for s in $(grep -oE '^CONFIG_[A-Z0-9_]+=y' "$BOARD/linux.fragment" | cut -d= -f1); do grep -q "^$s=y" .config || echo "NOT SET: $s"; done

#!/usr/bin/env bash
# The build environment for Buildroot on NixOS (no sudo): `vm-image/shell.sh vm-image/build.sh`. Buildroot wants a normal /usr (it checks /usr/bin/file), so the tools run in an FHS environment
# built from nixpkgs as a normal user.
set -euo pipefail
export NIX_CONFIG="experimental-features = nix-command flakes"
HERE=$(cd "$(dirname "$0")" && pwd)
FHS=${VF_IMAGE_FHS:-$HOME/vm-image-build/fhs}
[ -x "$FHS/bin/vf-image-fhs" ] || { mkdir -p "$(dirname "$FHS")"; nix build --impure -f "$HERE/fhs.nix" -o "$FHS"; }
exec "$FHS/bin/vf-image-fhs" -c "$*"

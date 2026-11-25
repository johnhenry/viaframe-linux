#!/bin/sh
# Buildroot post-build hook ($1 = the target directory): the C++ runtime is in the toolchain only so that host-rust can target musl; nothing in the image links against it (wsh-server is a static Rust binary).
set -e
rm -f "$1"/usr/lib/libstdc++* "$1"/usr/lib/libgcc_s* "$1"/lib/libgcc_s* 2>/dev/null || true
rm -rf "$1"/usr/share/gdb 2>/dev/null || true

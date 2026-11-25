################################################################################
#
# wsh-server
#
################################################################################

# The Rust workspace's tag (`rust-v0.18.0`). The patch is viaframe's single change (vm-image/README in the sources archive): `--plain-ws ADDR`.
WSH_SERVER_VERSION = rust-v0.18.0
WSH_SERVER_SITE = $(call github,johnhenry,wsh,$(WSH_SERVER_VERSION))
WSH_SERVER_SUBDIR = crates/wsh-server
WSH_SERVER_LICENSE = MIT
WSH_SERVER_LICENSE_FILES = LICENSE

# ring (the TLS crypto of the Rust crates) needs SSE2 on 32-bit x86, which the i586 target leaves off: turn it on for this one package (the C and assembler parts get -msse2 too). The kernel and every
# other package stay i586; v86 runs SSE2 (the wsh project's own i686-musl release runs in v86).
#
# Reproducible: two clean builds in different folders must give the same binary, and rustc and the C compiler write the build folder's path into it (panic messages, assertions). Every path that
# differs between machines is mapped to a fixed one (rustc applies the LAST matching mapping, so the broad $(HOME) comes first).
WSH_SERVER_CARGO_ENV = \
	CARGO_TARGET_I586_UNKNOWN_LINUX_MUSL_RUSTFLAGS="-C target-feature=+sse,+sse2 --remap-path-prefix=$(HOME)=/home --remap-path-prefix=$(BUILD_DIR)=/build --remap-path-prefix=$(HOST_DIR)=/host --remap-path-prefix=$(BR_CARGO_HOME)=/cargo --remap-path-prefix=$(DL_DIR)=/dl" \
	CFLAGS_i586_unknown_linux_musl="-msse2 -mfpmath=sse -ffile-prefix-map=$(BUILD_DIR)=/build -ffile-prefix-map=$(HOST_DIR)=/host -ffile-prefix-map=$(DL_DIR)=/dl"

$(eval $(cargo-package))

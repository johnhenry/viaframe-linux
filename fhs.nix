# An FHS build environment for Buildroot on NixOS (it insists on /usr/bin/file and a normal /usr, /lib). Built as a normal user: `nix build --impure -f vm-image/fhs.nix -o <dir>`.
let pkgs = (builtins.getFlake "nixpkgs").legacyPackages.${builtins.currentSystem}; in
pkgs.buildFHSEnv {
  name = "vf-image-fhs";
  targetPkgs = p: with p; [ gcc gnumake binutils perl python3 cpio unzip rsync bc file which wget curl patch gawk flex bison ncurses ncurses.dev openssl openssl.dev elfutils pkg-config diffutils findutils gnutar xz bzip2 gzip gnused gnugrep coreutils bash git libelf zlib zlib.dev gnum4 texinfo util-linux unzip ];
  runScript = "bash";
}

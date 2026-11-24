# viaframe-linux

A minimal Linux image for [viaframe](https://viaframe.johnhenry.me)'s vm pane, which runs it in the browser with [v86](https://github.com/copy/v86) (32-bit x86).

- **What's in it:** Buildroot 2026.02.3, Linux 6.19.14 (i586, tinyconfig plus `br2-external/board/viaframe/linux.fragment`), busybox 1.37.0 and musl 1.2.6, plus `vf-agent`, a small shell script that answers on `/dev/hvc0`. 9p (virtio) is used for the shared folder, with a serial console and a VGA console.
- **Output:** one `viaframe-linux.bzimage` (about 2.5 MB) with the root file system inside. It boots to a shell in about 3 s in v86.
- **Reproducible:** `BR2_REPRODUCIBLE=y` and `SOURCE_DATE_EPOCH` are set. Two clean builds in different folders give the same image hash.

## Build

```sh
./build.sh     # needs nix (fhs.nix provides the tools Buildroot expects); writes out/
```

`out/` holds the image, `viaframe-linux-sources.tar.gz` (the complete corresponding source: every package source with patches, licence texts, the Buildroot release and this recipe) and `SHA256SUMS`.

## Releases

Each release carries the image, the source archive, the package manifest and `SHA256SUMS`. viaframe's build downloads the image, checks its SHA-256 against its own lock file, and serves it from viaframe's origin.

## Licences

The image contains GPL-2.0 software (Linux, busybox), so the complete source is published next to every image as `viaframe-linux-sources.tar.gz`. See `licenses/` and the manifest. The recipe files in this repository are MIT.

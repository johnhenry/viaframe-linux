// Writes public/third-party/viaframe-linux-NOTICE.txt, the notice the built app serves (the vm pane links to it): what is in the hosted image, the licence texts, the written offer for the GPL source and the
// hashes of the image and of its source archive (from src/vm/image.lock.json). Run after a new build is locked: `node vm-image/make-notice.mjs`.
import { readFileSync, writeFileSync } from "node:fs";

const at = (p) => new URL(`../${p}`, import.meta.url);
const lock = JSON.parse(readFileSync(at("src/vm/image.lock.json"), "utf8")).images["viaframe-linux"];
const text = (p) => readFileSync(at(`vm-image/licenses/${p}`), "utf8").trimEnd();
const out = `viaframe Linux: the image the vm pane hosts
===========================================

This file is served with the app (third-party/viaframe-linux-NOTICE.txt). The vm pane boots a small Linux that viaframe builds with Buildroot ${lock.buildroot} (the recipe is public at
https://github.com/johnhenry/viaframe-linux). The image is one file, viaframe-linux.bzimage, a Linux kernel with its root file system inside.

  sha-256 of the image:                      ${lock.sha256}
  size:                                      ${lock.size} bytes
  sha-256 of the source archive:             ${lock.sourcesSha256}
  the source archive:                        ${lock.sourcesUrl}

What is in it
-------------
  Linux kernel 6.19.14        GPL-2.0 with the Linux syscall note       https://www.kernel.org/
  busybox 1.37.0              GPL-2.0                                   https://www.busybox.net/
  musl libc 1.2.6             MIT                                       https://musl.libc.org/
  wsh-server                  MIT (johnhenry/wsh tag rust-v0.18.0 with one patch, --plain-ws), with the Rust crates it is built from, each under MIT, Apache-2.0, ISC or BSD terms; their licence files are in the sources archive (the vendored crates)   https://github.com/johnhenry/wsh
  vf-agent (a shell script)   MIT, part of viaframe
  Built with GCC 14.3.0 (the compiler's runtime library is under the GCC Runtime Library Exception) and Buildroot ${lock.buildroot} (GPL-2.0-or-later).

Source for the GPL parts, and a written offer
---------------------------------------------
The complete corresponding source of everything above, with the patches that were applied, the Buildroot release it was built with, the Buildroot configuration, the kernel configuration, the busybox
fragment and the build scripts, is the file viaframe-linux-sources.tar.gz, published with the image. Rebuild the image yourself with vm-image/shell.sh vm-image/build.sh.

This is also a written offer. For three years from the day you received this image, the maintainer of viaframe (https://github.com/johnhenry/viaframe-linux) will give anyone who asks the complete
corresponding source of the GPL-licensed parts above, on a medium customarily used for software interchange, for no more than the cost of doing so.

Licence texts
-------------

----- GNU General Public License, version 2 (with busybox's note on versions), as shipped with busybox 1.37.0 -----

${text("GPL-2.0-busybox-LICENSE.txt")}

----- The Linux syscall note (an exception to the kernel's GPL-2.0 for programs that use its system calls) -----

${text("Linux-syscall-note.txt")}

----- musl libc 1.2.6: COPYRIGHT (MIT licence and the licences of the files it names) -----

${text("musl-1.2.6-COPYRIGHT.txt")}
`;
writeFileSync(at("public/third-party/viaframe-linux-NOTICE.txt"), out);
console.log(`wrote public/third-party/viaframe-linux-NOTICE.txt (${out.length} bytes)`);

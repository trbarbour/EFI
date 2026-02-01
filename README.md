# EFI

This repository stores firmware artifacts that are built in the Codex workspace.

## FTDI USB Serial DXE Driver

* **Binary**: Decode the text-safe copy at
  [`artifacts/FtdiUsbSerialDxe_X64.efi.base64`](artifacts/FtdiUsbSerialDxe_X64.efi.base64)
  to reconstruct `FtdiUsbSerialDxe_X64.efi` locally (`base64 -d` works well).
* **Checksum**: [`artifacts/FtdiUsbSerialDxe_X64.efi.sha256`](artifacts/FtdiUsbSerialDxe_X64.efi.sha256)
  (use `sha256sum -c` after decoding).
* **Source**: `edk2/CustomDrivers/FtdiUsbSerialDxe` (mirrors the upstream EDK II FTDI driver)
* **Build command** (run from `edk2/` after `source edksetup.sh`):
  ```bash
  build -p CustomDrivers/FtdiUsbSerialStandalone.dsc \
        -m CustomDrivers/FtdiUsbSerialDxe/FtdiUsbSerialDxe.inf \
        -a X64 -b RELEASE -t GCC5
  ```
* **Output**: `Build/FtdiUsbSerial/RELEASE_GCC5/X64/FtdiUsbSerialDxe.efi`
The X64 binary above was built on this branch for use with the Minix Z350-0dB's UEFI.

## Building the firmware with Nix

A `default.nix` expression is provided so that the EDK II UEFI Shell and the
FTDI USB Serial plus Terminal DXE drivers can be reproduced on NixOS.
Evaluating the expression reuses the pre-built shell from
`nixpkgs#edk2-uefi-shell`, fetches the upstream EDK II sources necessary for the
drivers, builds them with the standard BaseTools toolchain, and then stages the
firmware binaries under `$out/share/firmware`.

To build the firmware, run:

```bash
nix-build
```

The resulting symlink named `result` will contain:

* `share/firmware/Shell.efi`
* `share/firmware/FtdiUsbSerialDxe.efi`
* `share/firmware/TerminalDxe.efi`
* `share/firmware/Shell.nixpkgs.efi` (the reference shell binary that ships with
  `nixpkgs#edk2-uefi-shell`)

These three binaries can be copied onto a FAT-formatted USB stick and loaded by
UEFI firmware on the Minix Z350-0dB fanless mini-PC. The driver may also be
loaded from the UEFI shell using `load fs0:\EFI\FtdiUsbSerialDxe.efi` once the
USB stick has been mounted.

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

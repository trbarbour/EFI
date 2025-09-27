# FTDI USB Serial DXE Driver Artifact

This folder contains a Base64-encoded copy of the `FtdiUsbSerialDxe_X64.efi` binary so that it can be downloaded from web interfaces that block direct binary downloads.

## Downloading

1. Download `FtdiUsbSerialDxe_X64.efi.base64` from this folder.
2. Decode it back into the EFI binary:
   ```bash
   base64 -d FtdiUsbSerialDxe_X64.efi.base64 > FtdiUsbSerialDxe_X64.efi
   ```
3. (Optional) Verify the checksum recorded in this folder:
   ```bash
   sha256sum -c FtdiUsbSerialDxe_X64.efi.sha256
   ```

The decoded file matches the recorded checksum and is ready to copy onto your target media.

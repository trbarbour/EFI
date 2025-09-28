{ lib
, stdenv
, edk2
, edk2-uefi-shell
, fetchFromGitHub
, nasm
, util-linux
, python3
, llvmPackages
}:

let
  inherit (edk2) version;

  edk2PlatformsSrc = fetchFromGitHub {
    owner = "tianocore";
    repo = "edk2-platforms";
    rev = "996c79ee0ed5236a0449b20f2bec4162ab4185fd";
    hash = "sha256-4ckClAk05uBWqASrynRD7IZJA8PvQjCEV51IPQoWL6Q=";
  };

  edk2NonOsiSrc = fetchFromGitHub {
    owner = "tianocore";
    repo = "edk2-non-osi";
    rev = "94d048981116e2e3eda52dad1a89958ee404098d";
    hash = "sha256-6yuvVvmGn4yaEksbbvGDX1ZcKpdWBKnwaNjLGvgAWyk=";
  };

  toolchainTag = if stdenv.cc.isClang then "CLANGPDB" else "GCC5";

  driver = edk2.mkDerivation "FtdiUsbSerialStandalone.dsc" (
    finalAttrs:
    {
      pname = "edk2-ftdi-usb-serial";
      inherit version;

      nativeBuildInputs =
        [
          python3
          nasm
          util-linux
        ]
        ++ lib.optionals stdenv.cc.isClang [
          llvmPackages.bintools
          llvmPackages.llvm
        ];

      buildFlags =
        "-m OptionRomPkg/Bus/Usb/FtdiUsbSerialDxe/FtdiUsbSerialDxe.inf"
        + " -a X64 -b RELEASE -t ${toolchainTag}";

      preConfigure = ''
        cp -r ${edk2PlatformsSrc} ../edk2-platforms
        cp -r ${edk2NonOsiSrc} ../edk2-non-osi
        chmod -R u+w ../edk2-platforms ../edk2-non-osi
        workspace=$PWD
        platforms=$PWD/../edk2-platforms
        nonosi=$PWD/../edk2-non-osi
        export PACKAGES_PATH="$workspace:$platforms/Drivers:$platforms:$nonosi"

        cat > FtdiUsbSerialStandalone.dsc <<'EOF'
        [Defines]
          PLATFORM_NAME                  = FtdiUsbSerialStandalone
          PLATFORM_GUID                  = 7B3ED62D-4B2A-4FC5-9F63-FBB3C754738F
          PLATFORM_VERSION               = 0.1
          DSC_SPECIFICATION              = 0x00010005
          OUTPUT_DIRECTORY               = Build/FtdiUsbSerial
          SUPPORTED_ARCHITECTURES        = IA32|X64
          BUILD_TARGETS                  = DEBUG|RELEASE
          SKUID_IDENTIFIER               = DEFAULT

        [LibraryClasses]
          BaseLib|MdePkg/Library/BaseLib/BaseLib.inf
          UefiDriverEntryPoint|MdePkg/Library/UefiDriverEntryPoint/UefiDriverEntryPoint.inf
          StackCheckLib|MdePkg/Library/StackCheckLibNull/StackCheckLibNull.inf
          BaseMemoryLib|MdePkg/Library/BaseMemoryLib/BaseMemoryLib.inf
          DebugLib|MdePkg/Library/UefiDebugLibStdErr/UefiDebugLibStdErr.inf
          DebugPrintErrorLevelLib|MdePkg/Library/BaseDebugPrintErrorLevelLib/BaseDebugPrintErrorLevelLib.inf
          MemoryAllocationLib|MdePkg/Library/UefiMemoryAllocationLib/UefiMemoryAllocationLib.inf
          UefiBootServicesTableLib|MdePkg/Library/UefiBootServicesTableLib/UefiBootServicesTableLib.inf
          UefiLib|MdePkg/Library/UefiLib/UefiLib.inf
          UefiRuntimeServicesTableLib|MdePkg/Library/UefiRuntimeServicesTableLib/UefiRuntimeServicesTableLib.inf
          DevicePathLib|MdePkg/Library/UefiDevicePathLib/UefiDevicePathLib.inf
          PcdLib|MdePkg/Library/BasePcdLibNull/BasePcdLibNull.inf
          PrintLib|MdePkg/Library/BasePrintLib/BasePrintLib.inf
          RegisterFilterLib|MdePkg/Library/RegisterFilterLibNull/RegisterFilterLibNull.inf

        [Components]
          OptionRomPkg/Bus/Usb/FtdiUsbSerialDxe/FtdiUsbSerialDxe.inf
        EOF
      '';

      installPhase = ''
        runHook preInstall

        ftdi_out=$(find Build -name FtdiUsbSerialDxe.efi -print -quit)
        if [ -z "$ftdi_out" ]; then
          echo "unable to locate built FTDI driver" >&2
          exit 1
        fi
        install -Dm644 "$ftdi_out" $out/FtdiUsbSerialDxe.efi

        runHook postInstall
      '';

      dontStrip = true;
      dontPatchELF = true;
    }
  );
in
stdenv.mkDerivation {
  pname = "edk2-shell-ftdi";
  inherit version;

  src = null;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 ${edk2-uefi-shell}/shell.efi \
      $out/share/firmware/Shell.efi
    install -Dm644 ${driver}/FtdiUsbSerialDxe.efi \
      $out/share/firmware/FtdiUsbSerialDxe.efi
    install -Dm644 ${edk2-uefi-shell}/shell.efi \
      $out/share/firmware/Shell.nixpkgs.efi

    runHook postInstall
  '';

  passthru = {
    inherit driver;
    inherit (edk2-uefi-shell.passthru) efi;
  };

  meta = with lib; {
    description = "EDK II UEFI Shell and FTDI USB serial driver binaries";
    longDescription = ''
      This package reuses the pre-built UEFI shell from nixpkgs and compiles the
      FTDI USB Serial DXE driver so they can be deployed on systems such as the
      Minix Z350-0dB fanless x86 mini-PC.
    '';
    homepage = "https://github.com/tianocore/edk2";
    license = with licenses; [ bsd2 bsd3 ];
    maintainers = [ ];
    platforms = platforms.linux;
  };
}

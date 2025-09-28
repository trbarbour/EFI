{ pkgs ? import <nixpkgs> {} }:

pkgs.callPackage ./nix/edk2-shell-ftdi.nix {}

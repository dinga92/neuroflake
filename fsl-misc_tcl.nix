{pkgs ? import <nixpkgs> {}}: let
  fslBase = pkgs.callPackage ./fsl-base.nix {};
in
  pkgs.stdenv.mkDerivation {
    pname = "fsl-misc_tcl";
    version = "2406.0";

    src = pkgs.fetchgit {
      url = "https://git.fmrib.ox.ac.uk/fsl/misc_tcl.git";
      rev = "2406.0";
      sha256 = "sha256-x4KUZApFlFnWp0XTeKxxzz+8XSyO/rpJ+BYNIcG5ztA=";
    };

    buildInputs = [
      fslBase
    ];

    buildPhase = ''
      export FSLDIR=$out
      export FSLDEVDIR=$out

      mkdir -p $out/config
      ln -s ${fslBase}/config/* $out/config/.

      mkdir -p $out/etc/fslconf
      ln -s ${fslBase}/etc/fslconf/fsl.sh $out/etc/fslconf/fsl.sh

      source ${fslBase}/etc/fslconf/fsl-devel.sh

      make
    '';

    installPhase = ''
      make install
    '';

    meta = {
      description = "FSL misc_tcl module";
      homepage = "https://git.fmrib.ox.ac.uk/fsl/misc_tcl.git";
    };
  }

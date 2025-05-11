{pkgs ? import <nixpkgs> {}}: let
  fslBase = pkgs.callPackage ./fsl-base.nix {};
  fslArmawrap = pkgs.callPackage ./fsl-armawrap.nix {};
  fslCprob = pkgs.callPackage ./fsl-cprob.nix {};
  fslNewnifti = pkgs.callPackage ./fsl-newnifti.nix {};
  fslUtils = pkgs.callPackage ./fsl-utils.nix {};
  fslZnzlib = pkgs.callPackage ./fsl-znzlib.nix {};
in
  pkgs.stdenv.mkDerivation rec {
    pname = "fsl-miscmaths";
    version = "2412.5";

    src = pkgs.fetchgit {
      url = "https://git.fmrib.ox.ac.uk/fsl/miscmaths.git";
      rev = version;
      sha256 = "7rnKL7LOMwbMMTpSpLUAZc8LTjHsVkkZnQ/wEWhObxo=";
    };

    dontUseCmakeConfigure = true;

    buildInputs = [
      fslBase
      fslCprob
      fslNewnifti
      fslUtils
      fslZnzlib
      fslArmawrap
      pkgs.lapack
      pkgs.blas
      pkgs.gfortran
      pkgs.gfortran.cc
      pkgs.gcc
      pkgs.libz
    ];

    configurePhase = ''
      export FSLDIR=${fslBase}
      export FSLDEVDIR=${fslBase}
      ln -sfn ${fslBase}/config config
      source ${fslBase}/etc/fslconf/fsl-devel.sh
    '';

    buildPhase = ''
      make \
        FSLSWDIR=${fslBase} \
        FSLCONFDIR=${fslBase}/config
    '';

    installPhase = ''
      mkdir -p $out/etc

      export FSLDIR=$out
      export FSLDEVDIR=$out
      export FSLCONFDIR=${fslBase}/config

      make install \
           FSLSWDIR=${fslBase} \
           FSLCONFDIR=${fslBase}/config
    '';

    meta = {
      description = "FSL miscmaths module";
      homepage = "https://git.fmrib.ox.ac.uk/fsl/miscmaths.git";
    };
  }

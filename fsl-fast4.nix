{pkgs ? import <nixpkgs> {}}: let
  fslBase = pkgs.callPackage ./fsl-base.nix {};
  fslArmawrap = pkgs.callPackage ./fsl-armawrap.nix {};
  fslMiscmaths = pkgs.callPackage ./fsl-miscmaths.nix {};
  fslMiscTcl = pkgs.callPackage ./fsl-misc_tcl.nix {};
  fslNewimage = pkgs.callPackage ./fsl-newimage.nix {};
  fslNewnifti = pkgs.callPackage ./fsl-newnifti.nix {};
  fslUtils = pkgs.callPackage ./fsl-utils.nix {};
  fslZnzlib = pkgs.callPackage ./fsl-znzlib.nix {};
  fslCprob = pkgs.callPackage ./fsl-cprob.nix {};

  openblas = pkgs.openblas;
  lapack = pkgs.lapack;
  blas = pkgs.blas;
in
  pkgs.stdenv.mkDerivation rec {
    pname = "fsl-fast4";
    version = "2111.3";

    # src = pkgs.fetchgit {
    #   url = "https://git.fmrib.ox.ac.uk/fsl/fast4.git";
    #   rev = "2111.3";
    #   sha256 = "sha256-pvurhxjbvKShikJyL0lC3N2aXVln61vG0EGZ0IRfHig=";
    # };

    src = pkgs.fetchurl {
      url = "https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/public/linux-64/fsl-fast4-2111.3-hb6de94e_3.tar.bz2";
      sha256 = "sha256-S6wqrNoe44SRZfdkcDi5D1qslLnUUGvgpLmDGrrFw0Y=";
    };

    buildInputs = [
      fslArmawrap
      fslBase
      fslCprob
      fslMiscTcl
      fslMiscmaths
      fslNewimage
      fslNewnifti
      fslUtils
      fslZnzlib
      pkgs.openblas
      pkgs.stdenv.cc.cc
    ];

    unpackPhase = ''
      mkdir -p $out
      tar -xjf "$src" -C $out #--strip-components=1
    '';

    installPhase = ''

      mkdir $out/lib

      ln -sf ${fslCprob}/lib/libfsl-cprob.so $out/lib/
      ln -sf ${fslMiscmaths}/lib/libfsl-miscmaths.so $out/lib/
      ln -sf ${fslNewimage}/lib/libfsl-newimage.so $out/lib/
      ln -sf ${fslNewnifti}/lib/libfsl-NewNifti.so $out/lib/
      ln -sf ${fslUtils}/lib/libfsl-utils.so $out/lib/

      ln -s ${pkgs.openblas}/lib/liblapack.so.3   $out/lib/
      ln -s ${pkgs.openblas}/lib/libblas.so.3     $out/lib/
      ln -s ${pkgs.stdenv.cc.cc.lib}/lib/libstdc++.so.6 $out/lib/

      rm -r $out/info $out/src

    '';

    meta = {
      description = "FSL FAST4 module";
      homepage = "https://git.fmrib.ox.ac.uk/fsl/fast4.git";
    };
  }

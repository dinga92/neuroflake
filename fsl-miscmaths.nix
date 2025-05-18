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

    # src = pkgs.fetchgit {
    #   url = "https://git.fmrib.ox.ac.uk/fsl/miscmaths.git";
    #   rev = version;
    #   sha256 = "7rnKL7LOMwbMMTpSpLUAZc8LTjHsVkkZnQ/wEWhObxo=";
    # };

    src = pkgs.fetchurl {
      url = "https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/public/linux-64/fsl-miscmaths-2412.4-h982b8fd_0.tar.bz2";
      sha256 = "sha256-OuFLTaaUhcJdtqfd50fUcjaKG1sI48ZCmqAbfD5jvIM=";
      # sha256 = "0v1p5mwxznrkh2gpqk1jb9v6vw6s3q4b9nmz6fy0fzrk8fxjm1jz"; # update with real hash
    };

    buildInputs = [
      fslBase
      fslCprob
      fslNewnifti
      fslUtils
      fslZnzlib
      fslArmawrap
      pkgs.gfortran.cc
      pkgs.libz
      pkgs.gcc
      pkgs.blas
      pkgs.lapack
      pkgs.tree
    ];

    unpackPhase = ''
      mkdir -p $out
      tar -xjf "$src" -C $out --strip-components=1
    '';


    installPhase = ''
      mkdir $out/lib
      mv $out/libfsl-miscmaths.so $out/lib/

      mkdir $out/include
      mv $out/miscmaths $out/include

      cd $out
      rm about.json files fsl-miscmaths git hash_input.json has_prefix index.json paths.json recipe run_exports.json -r


    '';

    meta = {
      description = "FSL miscmaths module";
      homepage = "https://git.fmrib.ox.ac.uk/fsl/miscmaths.git";
    };
  }

{pkgs ? import <nixpkgs> {}}: let
  fslBase = pkgs.callPackage ./fsl-base.nix {};
  fslZnzlib = pkgs.callPackage ./fsl-znzlib.nix {};
in
  pkgs.stdenv.mkDerivation rec {
    pname = "fsl-newnifti";
    version = "4.1.0";

    src = pkgs.fetchgit {
      url = "https://git.fmrib.ox.ac.uk/fsl/NewNifti.git";
      rev = version;
      sha256 = "sha256-R4g+mFnmzcxTMGiKThiGxANi9ecxhY8uEQ+TKdkgKC0=";
    };

    buildInputs = [
      fslBase
      fslZnzlib
    ];

    configurePhase = ''
      export FSLDIR=${fslBase}
      export FSLDEVDIR=${fslBase}
      ln -sfn ${fslBase}/config config
      source ${fslBase}/etc/fslconf/fsl-devel.sh
    '';

    buildPhase = ''
      unset NIX_LDFLAGS
      make \
        ARCHLDFLAGS= \
        ARCHLIBS= \
        CXXFLAGS="$NIX_CXXFLAGS_COMPILE" \
        LDFLAGS="-L${fslZnzlib}/lib -lfsl-znz -ldl -pthread" \
        FSLCONFDIR=${fslBase}/config
    '';

    installPhase = ''
      mkdir -p $out/{bin,lib,include,config,etc}
      make install \
        verbose=v \
        PREFIX=$out \
        FSLDIR=$out \
        FSLDEVDIR=$out \
        FSLCONFDIR=${fslBase}/config
    '';

    meta = with pkgs.lib; {
      description = "FSL Utilities";
      homepage = "https://git.fmrib.ox.ac.uk/fsl/utils.git";
    };
  }

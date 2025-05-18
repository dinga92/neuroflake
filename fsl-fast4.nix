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

    src = pkgs.fetchgit {
      url = "https://git.fmrib.ox.ac.uk/fsl/fast4.git";
      rev = "2111.3";
      sha256 = "sha256-pvurhxjbvKShikJyL0lC3N2aXVln61vG0EGZ0IRfHig=";
    };

    buildInputs = [
      fslBase
      fslArmawrap
      fslMiscmaths
      fslMiscTcl
      fslNewimage
      fslNewnifti
      fslUtils
      fslZnzlib
      fslCprob
      pkgs.lapack
      pkgs.blas
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

    # buildPhase = ''
    #   export FSLDIR=$out
    #   export FSLDEVDIR=$out
    #
    #   # Ensure FSL configurations are in place
    #   mkdir -p $out/config
    #   ln -s ${fslBase}/config/* $out/config/.
    #
    #   mkdir -p $out/etc/fslconf
    #   ln -s ${fslBase}/etc/fslconf/fsl.sh $out/etc/fslconf/fsl.sh
    #
    #   source ${fslBase}/etc/fslconf/fsl-devel.sh
    #
    #   # Add LAPACK and BLAS to LDFLAGS
    #   export LDFLAGS="-L${pkgs.lapack}/lib -L${pkgs.blas}/lib $LDFLAGS"
    #
    #   mkdir -p $out/include
    #   ln -s ${fslArmawrap}/include/* $out/include/
    #
    #   # Run the build (make)
    #   make
    # '';

    meta = {
      description = "FSL FAST4 module";
      homepage = "https://git.fmrib.ox.ac.uk/fsl/fast4.git";
    };
  }

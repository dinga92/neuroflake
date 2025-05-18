{pkgs ? import <nixpkgs> {}}: let
  fslBase = pkgs.callPackage ./fsl-base.nix {};
  fslArmawrap = pkgs.callPackage ./fsl-armawrap.nix {};
  fslMiscmaths = pkgs.callPackage ./fsl-miscmaths.nix {};
  fslNewnifti = pkgs.callPackage ./fsl-newnifti.nix {};
  fslUtils = pkgs.callPackage ./fsl-utils.nix {};
  fslZnzlib = pkgs.callPackage ./fsl-znzlib.nix {};
  fslCprob = pkgs.callPackage ./fsl-cprob.nix {}; # should be provided by miscmaths?
in
  pkgs.stdenv.mkDerivation {
    pname = "fsl-newimage";
    version = "2501.4";

    src = pkgs.fetchgit {
      url = "https://git.fmrib.ox.ac.uk/fsl/newimage.git";
      rev = "2501.4";
      sha256 = "sha256-yfa7raBjuD/rHx1v5sp9Jc+J4fppKONo0WNqxYVeY3U=";
    };

    nativeBuildInputs = [
      pkgs.boost
    ];

    # TODO: fix transitive dependencies. Should we import the same dependencies again
    # that were supposed to be provided by other packages?
    buildInputs = [
      fslBase
      fslArmawrap
      fslMiscmaths
      fslNewnifti
      fslUtils
      fslZnzlib
      fslCprob
      pkgs.blas
      pkgs.lapack
      pkgs.zlib
    ];

    buildPhase = ''
      export FSLDIR=$out
      export FSLDEVDIR=$out

      mkdir -p $out/config
      ln -s ${fslBase}/config/* $out/config/.

      mkdir -p $out/etc/fslconf
      ln -s ${fslBase}/etc/fslconf/fsl.sh $out/etc/fslconf/fsl.sh

      mkdir -p $out/include
      ln -s ${fslArmawrap}/include/* $out/include/

      source ${fslBase}/etc/fslconf/fsl-devel.sh

      make
    '';

    installPhase = ''
      make install
    '';

    meta = {
      description = "FSL newimage module";
      homepage = "https://git.fmrib.ox.ac.uk/fsl/newimage.git";
      license = pkgs.lib.licenses.gpl3Plus;
    };
  }

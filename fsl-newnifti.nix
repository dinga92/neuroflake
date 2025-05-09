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

    nativeBuildInputs = [pkgs.gcc pkgs.coreutils];

    buildInputs = [
      fslBase
      fslZnzlib
    ];

    buildPhase = ''
      make CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS" \
           FSLSWDIR=${fslBase} \
           FSLCONFDIR=${fslBase}/config
    '';

    installPhase = ''

      mkdir -p $out/etc

      export FSLDIR=$out
      export FSLDEVDIR=$out
      export FSLCONFDIR=${fslBase}/config
      # export PATH=${pkgs.coreutils}/bin:$PATH

      # Verify paths before installation
      echo "FSLDIR contents:"
      ls -l $FSLDIR/etc

      make install \
           FSLSWDIR=${fslBase} \
           FSLCONFDIR=${fslBase}/config
    '';

    meta = with pkgs.lib; {
      description = "FSL Utilities";
      homepage = "https://git.fmrib.ox.ac.uk/fsl/utils.git";
      license = licenses.gpl3;
    };
  }

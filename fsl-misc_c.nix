{pkgs ? import <nixpkgs> {}}: let
  fslBase = pkgs.callPackage ./fsl-base.nix {};
  fslCprob = pkgs.callPackage ./fsl-cprob.nix {};
in
  pkgs.stdenv.mkDerivation rec {
    pname = "fsl-misc_c";
    version = "2111.0";

    src = pkgs.fetchgit {
      url = "https://git.fmrib.ox.ac.uk/fsl/misc_c.git";
      rev = version;
      sha256 = "sha256-+aEuDf7H0Z2oULHqBvltfQ4Z7HDt6Ds0rVS+Q1r9aZA=";
    };

    buildInputs = [fslBase fslCprob];

    buildPhase = ''
      make \
        CXXFLAGS="$CXXFLAGS -I. -I${fslCprob}/include" \
        CFLAGS="$CFLAGS -I. -I${fslCprob}/include" \
        LDFLAGS="$LDFLAGS -Wl,-rpath,${fslCprob}/lib -L${fslCprob}/lib -lfsl-cprob -lm" \
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

    meta = with pkgs.lib; {};
  }

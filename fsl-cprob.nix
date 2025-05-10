{pkgs ? import <nixpkgs> {}}: let
  fslBase = pkgs.callPackage ./fsl-base.nix {};
in
  pkgs.stdenv.mkDerivation rec {
    pname = "fsl-cprob";
    version = "2111.0";

    src = pkgs.fetchgit {
      url = "https://git.fmrib.ox.ac.uk/fsl/cprob.git";
      rev = version;
      sha256 = "sha256-wsnYbpmIIWNOHC4Ev30xdPAeKIv4YxWEfWxIE8267NQ=";
    };

    buildInputs = [fslBase];

    buildPhase = ''
      unset NIX_LDFLAGS

      make \
        ARCHLDFLAGS= \
        ARCHLIBS=     \
        LIBS=         \
        CXXFLAGS="$NIX_CXXFLAGS_COMPILE -static-libstdc++ -static-libgcc" \
        LDFLAGS="-pthread" \
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

    meta = with pkgs.lib; {
    };
  }

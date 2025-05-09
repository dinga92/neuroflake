{pkgs ? import <nixpkgs> {}}: let
  fslBase = pkgs.callPackage ./fsl-base.nix {};
in
  pkgs.stdenv.mkDerivation rec {
    pname = "fsl-cprop";
    version = "2111.0";

    src = pkgs.fetchgit {
      url = "https://git.fmrib.ox.ac.uk/fsl/cprob.git";
      rev = version;
      sha256 = "sha256-wsnYbpmIIWNOHC4Ev30xdPAeKIv4YxWEfWxIE8267NQ=";
    };

    buildInputs = [fslBase];

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

      make install \
           FSLSWDIR=${fslBase} \
           FSLCONFDIR=${fslBase}/config
    '';

    meta = with pkgs.lib; {
      license = licenses.gpl3;
    };
  }

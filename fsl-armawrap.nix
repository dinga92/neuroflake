# {pkgs ? import <nixpkgs> {}}: let
#   fslBase = pkgs.callPackage ./fsl-base.nix {};
# in
#   pkgs.stdenv.mkDerivation rec {
#     pname = "fsl-armawrap";
#     version = "0.7.0";
#
#     src = pkgs.fetchFromGitLab {
#       domain = "git.fmrib.ox.ac.uk";
#       owner = "fsl";
#       repo = "armawrap";
#       rev = version;
#       sha256 = "sha256-I13c2WtwV4rT63T9iP6VkVQ5uw9i2Sh9sfL797xBw7Y=";
#     };
#
#     buildInputs = [fslBase pkgs.armadillo pkgs.blas pkgs.lapack];
#     nativeBuildInputs = [pkgs.makeWrapper pkgs.blas pkgs.lapack];
#
#     postPatch = ''
#       substituteInPlace tests/run_tests.sh \
#         --replace '#!/bin/bash' '#!${pkgs.bash}/bin/bash'
#     '';
#
#     buildPhase = ''
#       make FSLSWDIR=${fslBase}/base FSLCONFDIR=${fslBase}/base/config
#       # make -C tests FSLSWDIR=${fslBase}/base FSLCONFDIR=${fslBase}/base/config
#     '';
#
#     checkInputs = [pkgs.lcov pkgs.gcc];
#     checkPhase = ''
#         export GCOV=${pkgs.gcc}/bin/gcov
#         export CXXFLAGS="-I${src}/armawrap -I${pkgs.armadillo}/include"
#
#         export LDFLAGS="-L${pkgs.blas}/lib -lblas -L${pkgs.lapack}/lib -llapack"
#
#
#       make -C tests FSLSWDIR=${fslBase}/base FSLCONFDIR=${fslBase}/base/config
#       make -C tests CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS" \
#         FSLSWDIR=${fslBase}/base FSLCONFDIR=${fslBase}/base/config
#       tests/run_tests.sh
#
#     '';
#     doCheck = true;
#
#     installPhase = ''
#       # armawrap headers
#       mkdir -p $out/include
#       cp -r ${src}/armawrap $out/include/
#
#       # Armadillo headers
#       cp -r ${pkgs.armadillo}/include/armadillo $out/include/
#       cp -r ${pkgs.armadillo}/include/armadillo_bits $out/include/
#     '';
#
#     meta = with pkgs.lib; {
#       description = "FSL Armawrap — header‑only Newmat API wrapper for Armadillo";
#       homepage = "https://git.fmrib.ox.ac.uk/fsl/armawrap";
#       maintainers = [];
#     };
#   }
{pkgs ? import <nixpkgs> {}}: let
  fslBase = pkgs.callPackage ./fsl-base.nix {};
in
  pkgs.stdenv.mkDerivation rec {
    pname = "fsl-armawrap";
    version = "0.7.0";

    src = pkgs.fetchFromGitLab {
      domain = "git.fmrib.ox.ac.uk";
      owner = "fsl";
      repo = "armawrap";
      rev = version;
      sha256 = "sha256-I13c2WtwV4rT63T9iP6VkVQ5uw9i2Sh9sfL797xBw7Y=";
    };

    # buildInputs = [fslBase pkgs.armadillo pkgs.openblas];
    # nativeBuildInputs = [pkgs.makeWrapper pkgs.openblas];

    postPatch = ''
      substituteInPlace tests/run_tests.sh \
        --replace '#!/bin/bash' '#!${pkgs.bash}/bin/bash'
    '';

    buildPhase = ''
      make FSLSWDIR=${fslBase} FSLCONFDIR=${fslBase}/config
    '';

    installPhase = ''
      mkdir -p $out/include
      cp -r ${src}/armawrap $out/include/
      cp -r ${pkgs.armadillo}/include/armadillo $out/include/
      cp -r ${pkgs.armadillo}/include/armadillo_bits $out/include/
    '';

    meta = with pkgs.lib; {
      description = "FSL Armawrap — header‑only Newmat API wrapper for Armadillo";
      homepage = "https://git.fmrib.ox.ac.uk/fsl/armawrap";
      maintainers = [];
    };
  }

# {pkgs ? import <nixpkgs> {}}: let
#   fslBase = pkgs.callPackage ./fsl-base.nix {};
#   fslArmawrap = pkgs.callPackage ./fsl-armawrap.nix {};
# in
#   pkgs.stdenv.mkDerivation rec {
#     pname = "fsl-utils";
#     version = "2412.1";
#
#     src = pkgs.fetchgit {
#       url = "https://git.fmrib.ox.ac.uk/fsl/utils.git";
#       rev = version;
#       sha256 = "sha256-TT3o8Qxqp2K/P55Wmy6hDLHv/zh1k/eaCJZ+MLp9jR0=";
#     };
#
#     nativeBuildInputs = [pkgs.gcc pkgs.coreutils];
#     buildInputs = [fslBase fslArmawrap];
#
#     preBuild = ''
#       patchShebangs .
#       # Remove hardcoded /bin in scripts
#       find . -type f -exec substituteInPlace {} \
#         --replace '/bin/mkdir' 'mkdir' \;
#     '';
#
#     buildPhase = ''
#       make CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS" \
#            FSLSWDIR=${fslBase}/base FSLCONFDIR=${fslBase}/base/config
#     '';
#
#     preInstall = ''
#       # Symlink fslversion
#       mkdir -p $out/etc
#       ln -s ${fslBase}/bin/fslversion $out/etc/fslversion
#
#       # Symlink fsl-devel.sh
#       mkdir -p $out/etc/fslconf
#       ln -s ${fslBase}/etc/fslconf/fsl-devel.sh $out/etc/fslconf/fsl-devel.sh
#     '';
#
#     # installPhase = ''
#     #   make install FSLSWDIR=$out FSLCONFDIR=${fslBase}/base/config
#     # '';
#
#     installPhase = ''
#       export FSLDIR=$out
#       export FSLDEVDIR=$out
#       export FSLSWDIR=$out
#       export FSLCONFDIR=${fslBase}/base/config
#
#       make install
#     '';
#
#     postBuild = ''
#       find .
#     '';
#
#     meta = with pkgs.lib; {
#       description = "FSL Utilities";
#       homepage = "https://git.fmrib.ox.ac.uk/fsl/utils.git";
#       license = licenses.gpl3;
#     };
#   }
{pkgs ? import <nixpkgs> {}}: let
  fslBase = pkgs.callPackage ./fsl-base.nix {};
  fslArmawrap = pkgs.callPackage ./fsl-armawrap.nix {};
in
  pkgs.stdenv.mkDerivation rec {
    pname = "fsl-utils";
    version = "2412.1";

    src = pkgs.fetchgit {
      url = "https://git.fmrib.ox.ac.uk/fsl/utils.git";
      rev = version;
      sha256 = "sha256-TT3o8Qxqp2K/P55Wmy6hDLHv/zh1k/eaCJZ+MLp9jR0=";
    };

    buildInputs = [fslBase fslArmawrap];

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
        ARCHLIBS=     \
        LIBS=         \
        CXXFLAGS="$NIX_CXXFLAGS_COMPILE" \
        LDFLAGS="-ldl -pthread -lstdc++ -lgcc_s" \
        FSLCONFDIR=${fslBase}/config
    '';

    installPhase = ''
      mkdir -p $out/{bin,lib,include,config,etc}

      make install \
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

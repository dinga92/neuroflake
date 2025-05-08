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

    nativeBuildInputs = [pkgs.gcc pkgs.coreutils];
    buildInputs = [fslBase fslArmawrap];

    buildPhase = ''
      make CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS" \
           FSLSWDIR=${fslBase} \
           FSLCONFDIR=${fslBase}/config
    '';

    installPhase = ''
      # Create fslversion explicitly (not a symlink)
      mkdir -p $out/etc
      cat ${fslBase}/bin/fslversion > $out/etc/fslversion

      # Ensure fsl-devel.sh exists
      mkdir -p $out/etc/fslconf
      cp ${fslBase}/etc/fslconf/fsl-devel.sh $out/etc/fslconf/

      export FSLDIR=$out
      export FSLDEVDIR=$out
      export FSLCONFDIR=${fslBase}/config
      export PATH=${pkgs.coreutils}/bin:$PATH

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

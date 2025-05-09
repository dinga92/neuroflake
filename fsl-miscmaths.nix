# {pkgs ? import <nixpkgs> {}}: let
#   fslBase = pkgs.callPackage ./fsl-base.nix {};
#   fslArmawrap = pkgs.callPackage ./fsl-armawrap.nix {};
#   fslCprob = pkgs.callPackage ./fsl-cprob.nix {};
#   fslNewnifti = pkgs.callPackage ./fsl-newnifti.nix {};
#   fslUtils = pkgs.callPackage ./fsl-utils.nix {};
#   fslZnzlib = pkgs.callPackage ./fsl-znzlib.nix {};
# in
#   pkgs.stdenv.mkDerivation rec {
#     pname = "fsl-miscmaths";
#     version = "2412.5";
#
#     src = pkgs.fetchgit {
#       url = "https://git.fmrib.ox.ac.uk/fsl/miscmaths.git";
#       rev = version;
#       sha256 = "sha256-7rnKL7LOMwbMMTpSpLUAZc8LTjHsVkkZnQ/wEWhObxo=";
#     };
#
#     buildInputs = [
#       fslBase
#       fslArmawrap
#       fslCprob
#       fslNewnifti
#       fslUtils
#       fslZnzlib
#     ];
#
#     nativeBuildInputs = [pkgs.cmake];
#
#     preConfigure = ''
#             # Add missing CMake project configuration
#             sed -i '1i\
#       cmake_minimum_required(VERSION 3.9)\
#       project(fsl-miscmaths LANGUAGES CXX)\
#       ' CMakeLists.txt
#
#             # Add installation rules
#             echo 'install(TARGETS miscmaths ARCHIVE DESTINATION lib)' >> CMakeLists.txt
#             echo 'install(FILES *.h DESTINATION include/miscmaths)' >> CMakeLists.txt
#     '';
#
#     cmakeFlags = [
#       "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
#       "-DFSLCONFDIR=${fslBase}/config"
#       "-DFSLSWDIR=${fslBase}"
#     ];
#   }
{pkgs ? import <nixpkgs> {}}: let
  fslBase = pkgs.callPackage ./fsl-base.nix {};
  fslArmawrap = pkgs.callPackage ./fsl-armawrap.nix {};
  fslCprob = pkgs.callPackage ./fsl-cprob.nix {};
  fslNewnifti = pkgs.callPackage ./fsl-newnifti.nix {};
  fslUtils = pkgs.callPackage ./fsl-utils.nix {};
  fslZnzlib = pkgs.callPackage ./fsl-znzlib.nix {};
in
  pkgs.stdenv.mkDerivation rec {
    pname = "fsl-miscmaths";
    version = "2412.5";

    src = pkgs.fetchgit {
      url = "https://git.fmrib.ox.ac.uk/fsl/miscmaths.git";
      rev = version;
      sha256 = "sha256-7rnKL7LOMwbMMTpSpLUAZc8LTjHsVkkZnQ/wEWhObxo=";
    };

    dontUseCmakeConfigure = true;

    buildInputs = [
      fslBase
      fslArmawrap
      fslCprob
      fslNewnifti
      fslUtils
      fslZnzlib
      pkgs.blas
      pkgs.lapack
      pkgs.zlib
    ];

    # buildPhase = ''
    #   # export FSLDIR=${fslBase}
    #   # export FSLDEVDIR=${fslBase}
    #
    #   export FSLDIR=${placeholder "$out"}
    #   export FSLDEVDIR=${placeholder "$out"}
    #   source ${fslBase}/etc/fslconf/fsl-devel.sh
    #   make
    # '';
    #
    # installPhase = ''
    #   # export FSLDIR=${fslBase}
    #   # export FSLDEVDIR=${fslBase}
    #
    #   export FSLDIR=${placeholder "$out"}
    #   export FSLDEVDIR=${placeholder "$out"}
    #   source ${fslBase}/etc/fslconf/fsl-devel.sh
    #   make install
    # '';

    buildPhase = ''
      export FSLDIR=$out
      export FSLDEVDIR=$out

      mkdir -p $out/config
      # Link the missing default.mk from fslBase (if available) or create it
      ln -s ${fslBase}/config/* $out/config/.

      # Continue with the rest of the build process
      mkdir -p $out/etc/fslconf
      ln -s ${fslBase}/etc/fslconf/fsl.sh $out/etc/fslconf/fsl.sh
      # ln -s ${fslBase}/include $out/include
      # ln -s ${fslBase}/lib $out/lib

      source ${fslBase}/etc/fslconf/fsl-devel.sh
      make
    '';

    installPhase = ''
      export FSLDIR=$out
      export FSLDEVDIR=$out

      make install
    '';

    meta = {
      description = "FSL miscmaths module";
      homepage = "https://git.fmrib.ox.ac.uk/fsl/miscmaths.git";
      license = pkgs.lib.licenses.gpl2;
    };
  }

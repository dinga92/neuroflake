# {pkgs ? import <nixpkgs> {}}: let
#   fslBase = pkgs.callPackage ./fsl-base.nix {};
# in
#   pkgs.stdenv.mkDerivation rec {
#     pname = "fsl-znzlib";
#     version = "2111.0";
#
#     src = pkgs.fetchgit {
#       url = "https://git.fmrib.ox.ac.uk/fsl/znzlib.git";
#       rev = version;
#       sha256 = "sha256-cTRxxf27pt6eBejbSdiLeIP2nk/P/xCcxtUUvG4OT+Y=";
#     };
#
#     nativeBuildInputs = [pkgs.gcc pkgs.coreutils];
#     buildInputs = [fslBase pkgs.zlib];
#
#     buildPhase = ''
#       make CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS" \
#            FSLSWDIR=${fslBase} \
#            FSLCONFDIR=${fslBase}/config
#     '';
#
#     installPhase = ''
#
#       mkdir -p $out/etc
#
#       export FSLDIR=$out
#       export FSLDEVDIR=$out
#       export FSLCONFDIR=${fslBase}/config
#       # export PATH=${pkgs.coreutils}/bin:$PATH
#
#       # Verify paths before installation
#       echo "FSLDIR contents:"
#       ls -l $FSLDIR/etc
#
#       make install \
#            FSLSWDIR=${fslBase} \
#            FSLCONFDIR=${fslBase}/config
#
#       mkdir -p $out/include
#       ln -s ${pkgs.zlib.dev}/include/zlib.h $out/include/zlib.h
#
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
in
  pkgs.stdenv.mkDerivation rec {
    pname = "fsl-znzlib";
    version = "2111.0";

    src = pkgs.fetchgit {
      url = "https://git.fmrib.ox.ac.uk/fsl/znzlib.git";
      rev = version;
      sha256 = "sha256-cTRxxf27pt6eBejbSdiLeIP2nk/P/xCcxtUUvG4OT+Y=";
    };

    nativeBuildInputs = [pkgs.gcc];
    buildInputs = [fslBase pkgs.zlib];

    configurePhase = ''
      # Set up FSL environment variables
      export FSLDIR=${fslBase}
      export FSLDEVDIR=${fslBase}

      # Link configuration directory
      ln -sfn ${fslBase}/config config

      # Source FSL development environment
      source ${fslBase}/etc/fslconf/fsl-devel.sh
    '';

    buildPhase = ''
      # Build with proper compiler flags

      make \
        CFLAGS="-I${pkgs.zlib.dev}/include -fPIC"\
        LDFLAGS="-L${pkgs.zlib}/lib -lz" \
        FSLCONFDIR=${fslBase}/config
    '';

    installPhase = ''
      # Create output directories
      mkdir -p $out/{lib,include}

      # Install library manually
      install -Dm755 libfsl-znz.so $out/lib/

      # Install headers
      install -Dm644 znzlib.h $out/include/

      # Link zlib header if needed
      ln -sf ${pkgs.zlib.dev}/include/zlib.h $out/include/zlib.h

      mkdir -p $out/include/znzlib
      install -Dm644 znzlib.h $out/include/znzlib/
      install -Dm755 libfsl-znz.so $out/lib/
    '';

    meta = with pkgs.lib; {
      description = "FSL znzlib - NIfTI I/O library";
      homepage = "https://git.fmrib.ox.ac.uk/fsl/znzlib";
      license = licenses.gpl3;
    };
  }

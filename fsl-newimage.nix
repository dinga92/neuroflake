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

    # src = pkgs.fetchgit {
    #   url = "https://git.fmrib.ox.ac.uk/fsl/newimage.git";
    #   rev = "2501.4";
    #   sha256 = "sha256-yfa7raBjuD/rHx1v5sp9Jc+J4fppKONo0WNqxYVeY3U=";
    # };

    src = pkgs.fetchurl {
      url = "https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/public/linux-64/fsl-newimage-2501.4-h500b71b_0.tar.bz2";
      sha256 = "sha256-M0lIIRMxAmoVBosGI5AzKXJK36pgKxw6/pw7KTkDBrI=";
    };

    nativeBuildInputs = [
      pkgs.boost
    ];

    buildInputs = [
      fslArmawrap
      fslBase
      fslCprob
      fslMiscmaths
      fslNewnifti
      fslUtils
      fslZnzlib
      pkgs.blas
      pkgs.lapack
      pkgs.zlib
      pkgs.stdenv.cc.cc
    ];

    unpackPhase = ''
      mkdir -p $out
      tar -xjf "$src" -C $out --strip-components=1
    '';

    # installPhase = ''
    #   export FSLDIR=$out
    #   export FSLDEVDIR=$out
    #
    #   mkdir -p $out/config
    #   ln -s ${fslBase}/config/* $out/config/.
    #
    #   mkdir -p $out/etc/fslconf
    #   ln -s ${fslBase}/etc/fslconf/fsl.sh $out/etc/fslconf/fsl.sh
    #
    #   mkdir -p $out/include
    #   ln -s ${fslArmawrap}/include/* $out/include/
    #
    #   source ${fslBase}/etc/fslconf/fsl-devel.sh
    #
    #   mkdir $out/lib
    #
    #   ln -sf ${fslCprob}/lib/libfsl-cprob.so $out/lib/
    #   ln -sf ${fslMiscmaths}/lib/libfsl-miscmaths.so $out/lib/
    #   ln -sf ${fslNewnifti}/lib/libfsl-NewNifti.so $out/lib/
    #   ln -sf ${fslUtils}/lib/libfsl-utils.so $out/lib/
    #   ln -sf ${fslZnzlib}/lib/libfsl-znzlib.so $out/lib/
    #
    #   ln -s ${pkgs.lapack}/lib/liblapack.so.3   $out/lib/
    #   ln -s ${pkgs.blas}/lib/libblas.so.3     $out/lib/
    #   ln -s ${pkgs.stdenv.cc.cc.lib}/lib/libstdc++.so.6 $out/lib/
    # '';

    installPhase = ''
      mkdir $out/lib
      mv $out/libfsl-newimage.so $out/lib/

      mkdir $out/include
      mv $out/newimage $out/include

      cd $out
      rm about.json files fsl-newimage git hash_input.json has_prefix index.json paths.json recipe run_exports.json -r

      ln -sf ${fslNewnifti}/lib/libfsl-NewNifti.so $out/lib/
      ln -sf ${fslUtils}/lib/libfsl-utils.so $out/lib/
      ln -sf ${fslCprob}/lib/libfsl-cprob.so $out/lib/
      ln -sf ${fslMiscmaths}/lib/libfsl-miscmaths.so $out/lib/

      ln -s ${pkgs.openblas}/lib/liblapack.so.3   $out/lib/
      ln -s ${pkgs.openblas}/lib/libblas.so.3     $out/lib/
      ln -s ${pkgs.stdenv.cc.cc.lib}/lib/libstdc++.so.6 $out/lib/
    '';

    meta = {
      description = "FSL newimage module";
      homepage = "https://git.fmrib.ox.ac.uk/fsl/newimage.git";
      license = pkgs.lib.licenses.gpl3Plus;
    };
  }

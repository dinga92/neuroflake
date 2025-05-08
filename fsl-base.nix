{pkgs ? import <nixpkgs> {}}:
# no runtime dependencies:
# - fsl-installer - no need installer in installed packages
# - fslpy - used for fsleyes, don't needed in base package
# - fsl-sub - used for submitting stuff to cluster. Maybe needed
# - tk - for gui, not needed in the base package
pkgs.stdenv.mkDerivation rec {
  pname = "fsl-base";
  version = "2504.3";

  src = pkgs.fetchFromGitLab {
    domain = "git.fmrib.ox.ac.uk";
    owner = "fsl";
    repo = "base";
    rev = version;
    sha256 = "sha256-/aeXyPcdynKujxWDMjpfVGB5Sbt4w1EG5rXNoZ0khXU";
  };

  nativeBuildInputs = with pkgs; [
    python3
    python3.pkgs.pip
    python3.pkgs.wheel
    python3.pkgs.setuptools-scm
    makeWrapper
    git
  ];

  buildInputs = with pkgs; [
    python3.pkgs.setuptools
    python3.pkgs.pyyaml
  ];

  propagatedBuildInputs = with pkgs; [
    python3.pkgs.pyyaml
  ];

  preBuild = ''
    export PIP_NO_INDEX=1
    export PIP_NO_BUILD_ISOLATION=1
    export SETUPTOOLS_SCM_PRETEND_VERSION="${version}"
  '';

  prePatch = ''
    # Create a working copy of source files
    cp -r $src ./source
    chmod -R +w ./source

    # Remove the license entry and substitute with a proper one
    sed -i '/^license *= *"Apache-2.0"/d' ./source/python/pyproject.toml

    # Apply patches to working copy
    substituteInPlace ./source/python/pyproject.toml \
      --replace 'license = "Apache-2.0"' \
                'license = { text = "Apache-2.0" }'

    # Replace mkdir references with the local version
    substituteInPlace ./source/config/rules.mk \
      --replace '/bin/mkdir' 'mkdir'

    substituteInPlace ./source/config/buildSettings.mk \
      --replace '/bin/mkdir' 'mkdir'

    substituteInPlace ./source/Makefile \
      --replace '/bin/mkdir' 'mkdir'

    # Modify Makefile to ensure proper pip install options
    substituteInPlace source/Makefile \
      --replace \
      '/bin/python -m pip install ./python' \
      '/bin/python -m pip install --no-build-isolation --no-index ./python'

    # If the .git metadata is missing, set a dummy version using setuptools-scm
    export SETUPTOOLS_SCM_PRETEND_VERSION="${version}"
  '';

  buildPhase = ''
    # Set up environment variables
    export FSLDIR=$out
    export FSLDEVDIR=$out

    # Build from modified source
    cp -r ./source ./build
    chmod -R +w ./build

    mkdir -p $out/bin
    ln -sf ${pkgs.python3}/bin/python $out/bin/python

    make -C ./build
  '';

  installPhase = ''
    export FSLDIR=$out
    export FSLDEVDIR=$out
    make -C ./build install

    site_pkgs="$out/lib/python3.11/site-packages"
    mkdir -p "$out/fsl"
    cp -r "$site_pkgs/fsl/base" "$out/fsl/"
    cp -r "$site_pkgs"/fsl_base-*.dist-info "$out/"
  '';

  postFixup = ''
    mv $out/share/doc $out/doc
    rm -rf $out/lib
    rm -rf $out/lib/python*/site-packages/**/__pycache__
    rm -rf $out/fsl/**/__pycache__
  '';

  meta = with pkgs.lib; {
    description = "FSL base infrastructure";
    platforms = platforms.unix;
  };
}

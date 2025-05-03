{pkgs ? import <nixpkgs> {}}: let
  py = pkgs.python3Packages;

  # Import the fslpy and fsleyes-widgets dependencies
  fslpy = import ./fslpy.nix {inherit pkgs;};
  fsleyesWidgets = import ./fsleyes-widgets.nix {inherit pkgs;};
  fsleyesProps = import ./fsleyes-props.nix {inherit pkgs;};
  filetree = import ./file-tree.nix {inherit pkgs;};
  filetree-fsl = import ./file-tree-fsl.nix {inherit pkgs;};
in
  py.buildPythonPackage rec {
    pname = "fsleyes";
    version = "1.14.2";
    format = "pyproject";

    src = pkgs.fetchFromGitLab {
      domain = "git.fmrib.ox.ac.uk";
      owner = "fsl";
      repo = "fsleyes/fsleyes";
      rev = "047a53e48f9c5829a372e647deb980eda4e33afd";
      sha256 = "sha256-93n3+jKXn//ogiai9VnrVNr4zFO4xcXPGwHVKs0xJgA=";
    };

    # Add fslpy and fsleyes-widgets to the propagated build inputs
    propagatedBuildInputs = with py; [
      jinja2
      pillow
      pyopengl
      numpy
      wxpython
      matplotlib
      nibabel
      pyparsing
      scipy
      fslpy
      fsleyesWidgets
      fsleyesProps
      # filetree
      # filetree-fsl
      pkgs.gtk3
      pkgs.glib
    ];

    nativeBuildInputs = [pkgs.wrapGAppsHook3];

    buildInputs = [py.setuptools pkgs.mesa pkgs.libGL];

    nativeCheckInputs = with py; [
      pytest
      coverage
      pytest-cov
      pkgs.xvfb-run
      pkgs.mesa-demos
    ];

    checkPhase = ''
      # Create temporary config/cache directories
      export XDG_CONFIG_HOME=$(mktemp -d)
      export XDG_CACHE_HOME=$(mktemp -d)
      mkdir -p $XDG_CACHE_HOME/fontconfig

      # Create custom fontconfig file
      export FONTCONFIG_PATH="$XDG_CONFIG_HOME/fontconfig"
      mkdir -p $FONTCONFIG_PATH
      cp ${pkgs.fontconfig.out}/etc/fonts/fonts.conf $FONTCONFIG_PATH/

      # Modify CACHEDIR in the copied config (not the store path)
      sed -i "s|~/.fontconfig|$XDG_CACHE_HOME/fontconfig|g" \
        $FONTCONFIG_PATH/fonts.conf

      # Point to our custom config
      export FONTCONFIG_FILE=$FONTCONFIG_PATH/fonts.conf

      # Software rendering setup
      export LIBGL_ALWAYS_SOFTWARE=1
      export MESA_GL_VERSION_OVERRIDE=3.3

      # Python path
      export PYTHONPATH=$PWD:$PYTHONPATH

      # Run tests
      xvfb-run -a -s "-screen 0 1024x768x24 -extension GLX" \
        pytest -v fsleyes/tests/test_annotations.py \
          --capture=no \
          --color=yes
    '';

    doCheck = true; # Enable running tests
  }

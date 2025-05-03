{pkgs ? import <nixpkgs> {}}: let
  py = pkgs.python3Packages;

  # Import the fslpy and fsleyes-widgets dependencies
  fslpy = import ./fslpy.nix {inherit pkgs;};
  fsleyesWidgets = import ./fsleyes-widgets.nix {inherit pkgs;};
in
  py.buildPythonPackage rec {
    pname = "fsleyes-props";
    version = "1.12.0";
    format = "pyproject";

    src = pkgs.fetchFromGitLab {
      domain = "git.fmrib.ox.ac.uk";
      owner = "fsl";
      repo = "fsleyes/props";
      rev = "5bfeb8a6c1da2b0b4d432801ff0f9f58a01ee39d";
      sha256 = "sha256-6ILw5+iZiYs49dYMePrPQ2MOGdxkrQeq4RluAltpWhs=";
    };

    # Add fslpy and fsleyes-widgets to the propagated build inputs
    propagatedBuildInputs = with py; [
      numpy
      wxpython
      matplotlib
      fslpy
      fsleyesWidgets
    ];

    buildInputs = [py.setuptools];

    nativeCheckInputs = with py; [
      pytest
      coverage
      pytest-cov
    ];

    doCheck = true;

    checkPhase = ''
      pytest fsleyes_props/tests \
        -k "not test_property_colourmap and not test_widget_boolean and not test_widget_bounds and not test_widget_number and not test_widget_point" \
        --tb=no -q --disable-warnings
    '';
  }

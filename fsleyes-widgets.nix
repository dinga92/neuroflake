{pkgs ? import <nixpkgs> {}}: let
  py = pkgs.python3Packages;
  # # Import fslpy.nix to include fslpy as a dependency
  # fslpy = import ./fslpy.nix {inherit pkgs;};
in
  py.buildPythonPackage rec {
    pname = "fsleyes-widgets";
    version = "0.15.0";
    format = "pyproject";

    src = pkgs.fetchFromGitLab {
      domain = "git.fmrib.ox.ac.uk";
      owner = "fsl";
      repo = "fsleyes/widgets";
      rev = "9044d52dc6569dd0a75529259d006767e8d33967";
      sha256 = "sha256-Rue0v6ITishtUvqKme4blHYfyRN7T57q4vWEhm37IdI=";
    };

    # Add fslpy as a propagated build input
    propagatedBuildInputs = with py; [
      numpy
      wxpython
      matplotlib
      # fslpy # Add fslpy to the propagated build inputs
      dill
      h5py
      nibabel
      scipy

      pytest
      pytest-cov
    ];

    buildInputs = [py.setuptools];

    nativeCheckInputs = with py; [
      pytest
      pytest-cov
    ];

    doCheck = false;

    checkPhase = ''
      pytest fsleyes_widgets/tests --tb=no -q
    '';
  }

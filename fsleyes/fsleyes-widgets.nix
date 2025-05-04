{pkgs ? import <nixpkgs> {}}: let
  py = pkgs.python3Packages;
in
  py.buildPythonPackage {
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

    propagatedBuildInputs = with py; [
      numpy
      wxpython
      matplotlib
    ];

    buildInputs = [py.setuptools ];

    nativeCheckInputs = (with py; [
      pytest
      pytest-cov
    ]) ++ [ pkgs.xvfb-run ];

    doCheck = true;

    checkPhase = ''
      # pytest fsleyes_widgets/tests --tb=no -q
      xvfb-run -s "-screen 0 800x600x24" pytest fsleyes_widgets/tests --tb=no -q
    '';
  }

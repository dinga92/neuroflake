{pkgs ? import <nixpkgs> {}}:
pkgs.python3Packages.buildPythonPackage rec {
  pname = "file-tree";
  version = "1.6.0";

  format = "pyproject";

  src = pkgs.fetchFromGitLab {
    domain = "git.fmrib.ox.ac.uk";
    owner = "fsl";
    repo = "file-tree";
    rev = "f5e5164e022aabdcb45a05e6bfb3d60fde99aa4a";
    sha256 = "sha256-jGR4ebtbq4QUg2N01+c+WgZvRSp2dSyCIycAFBW74a4=";
  };

  nativeBuildInputs = with pkgs.python3Packages; [
    hatchling
  ];

  propagatedBuildInputs = with pkgs.python3Packages; [
    numpy
    xarray
    pandas
    parse
    rich
  ];

  nativeCheckInputs = with pkgs.python3Packages; [
    ipython
    pytest
    pytest-cov
    pytest-mock
    pytest-textual-snapshot
    pytest-asyncio
  ];

  checkPhase = ''
    pytest src/tests/ --ignore src/tests/test_app.py
  '';

  doCheck = true;

  meta = with pkgs.lib; {
    description = "Describe structure directory for visualisation and pipeline";
    homepage = "https://git.fmrib.ox.ac.uk/fsl/file-tree";
    license = licenses.mit;
    maintainers = [];
  };
}

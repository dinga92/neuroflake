{pkgs ? import <nixpkgs> {}}: let
  py = pkgs.python3Packages;
in
  py.buildPythonPackage rec {
    pname = "fslpy";
    version = "3.22.0";
    format = "pyproject";

    src = pkgs.fetchFromGitLab {
      domain = "git.fmrib.ox.ac.uk";
      owner = "fsl";
      repo = "fslpy";
      rev = "3d8e6cdd626b882874e07d12fb577c20dbeb133a";
      # sha256 = "sha256-FmXYYdgjv+9vbo+SsgE1KUg7GVhZkWw0LWLy7hm/Sig=";
      sha256 = "sha256-DmDhIJa8jC+JJRbD3UsLun8xAyyPKLEl5FmoZEPLUV8=";
    };

    propagatedBuildInputs = with py; [
      dill
      h5py
      nibabel
      numpy
      scipy
      wxpython
      trimesh
      rtree
      indexed-gzip
      pkgs.dcm2niix
      pillow
      pytest
    ];

    buildInputs = [py.setuptools];

    nativeCheckInputs = with py; [
      pytest
      coverage
      pytest-cov
    ];

    doCheck = true;

    checkPhase = ''
        # disable because they require FSL or FSL path, X server, network access, creating or accessing non-existent test files, etc.
       pytest fsl/tests/ --tb=no -q --disable-warnings \
      -m "not fsltest and not wxtest and not dicomtest and not noroottest and not longtest and not unixtest" \
      --ignore=fsl/tests/test_fslsub.py --ignore=fsl/tests/test_wrappers
    '';
  }

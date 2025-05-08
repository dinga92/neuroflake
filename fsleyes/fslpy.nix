{pkgs ? import <nixpkgs> {}}: let
  py = pkgs.python3Packages;
in
  py.buildPythonPackage {
    pname = "fslpy";
    version = "3.22.0";
    format = "pyproject";

    src = pkgs.fetchFromGitLab {
      domain = "git.fmrib.ox.ac.uk";
      owner = "fsl";
      repo = "fslpy";
      rev = "3d8e6cdd626b882874e07d12fb577c20dbeb133a";
      sha256 = "sha256-DmDhIJa8jC+JJRbD3UsLun8xAyyPKLEl5FmoZEPLUV8=";
    };

    propagatedBuildInputs = with py; [
      dill
      numpy
      scipy
      h5py
      nibabel
      wxpython
      trimesh
      rtree
      indexed-gzip
      pkgs.dcm2niix
      pillow
    ];

    buildInputs = [py.setuptools];

    nativeCheckInputs = with py; [
      pytest
      coverage
      pytest-cov
      pkgs.xvfb-run
    ];

    doCheck = true;

    checkPhase = ''
      # Run tests with virtual display, excluding tests that:
      # - Require FSL or network access, or fail because they are mocking files
      xvfb-run -s "-screen 0 800x600x24" \
        pytest fsl/tests/ -q --tb=no --disable-warnings \
        -m "not fsltest and not dicomtest" \
        --ignore=fsl/tests/test_fslsub.py \
        --ignore=fsl/tests/test_run.py \
        --ignore=fsl/tests/test_wrappers
    '';
  }

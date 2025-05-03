{pkgs ? import <nixpkgs> {}}: let
  python = pkgs.python3;
  pythonPackages = python.pkgs;

  # Importing the file-tree package
  fileTree = import ./file-tree.nix {pkgs = pkgs;};
in
  pythonPackages.buildPythonPackage rec {
    pname = "file-tree-fsl";
    version = "0.2.3";

    src = pkgs.fetchFromGitLab {
      domain = "git.fmrib.ox.ac.uk";
      owner = "fsl";
      repo = "file-tree-fsl";
      rev = "baa400553c8c1208829c1239ec8343ea39210aa8";
      sha256 = "sha256-LiGgbi5zAAxXZ9v8h6rA+SB6gaml8SZJBy7dv13pve8=";
    };

    nativeBuildInputs = with pythonPackages; [
      setuptools
      hatchling
    ];

    propagatedBuildInputs = with pythonPackages; [
      fileTree
    ];

    # Package the .tree files from 'trees/' folder
    meta = with pkgs.lib; {
      description = "Filetree definitions for the FSL neuroimaging library";
      homepage = "https://git.fmrib.ox.ac.uk/fsl/file-tree-fsl";
      license = licenses.mit;
      maintainers = [];
    };

    doCheck = false;
  }

{pkgs ? import <nixpkgs> {}}: let
  py = pkgs.python3Packages;

  # Import the fslpy and fsleyes-widgets dependencies
  fslpy = import ./fslpy.nix {inherit pkgs;};
  fsleyesWidgets = import ./fsleyes-widgets.nix {inherit pkgs;};
  fsleyesProps = import ./fsleyes-props.nix {inherit pkgs;};
  filetree = import ./file-tree.nix {inherit pkgs;};
  filetree-fsl = import ./file-tree-fsl.nix {inherit pkgs;};
in
  py.buildPythonPackage {
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
      filetree
      filetree-fsl
      pkgs.libnotify
      pkgs.pcre2
      pkgs.SDL2
      pkgs.gtk3
      pkgs.glib
      pkgs.libGL
      pkgs.libGLU
      pkgs.libglibutil
      pkgs.gtkmm3
      pygobject3
      pkgs.mesa
      pkgs.libGL
      pkgs.xorg.libX11
      pkgs.xorg.libXext
      pkgs.xorg.libXrender
      pkgs.xorg.libxshmfence
      pkgs.dav1d
      pkgs.librsvg
      pkgs.glibc
      pkgs.glibc_multi
      pkgs.openjpeg
      pkgs.libyaml
      pkgs.gobject-introspection

      indexed-gzip
      ipykernel
      ipython
      jupyter_client
     nbclassic
      pyzmq
      rtree
     tornado
      trimesh
      xnatpy
    ];

    nativeBuildInputs = [pkgs.wrapGAppsHook3];

    buildInputs = [py.setuptools  ];

    nativeCheckInputs = with py; [
      pkgs.autoPatchelfHook
      pkgs.patchelf
      pkgs.xvfb-run
      pytest
      coverage
      pytest-cov
    ];

    checkPhase = ''
      # Run tests
      xvfb-run -s "-screen 0 1024x768x24"  pytest fsleyes/tests/ --tb=no -q --ignore=fsleyes/tests/test_displayspace.py --ignore=fsleyes/tests/test_displaycontext.py

    '';

    doCheck = false;
  }

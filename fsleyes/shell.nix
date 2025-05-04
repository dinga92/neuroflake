{pkgs ? import <nixpkgs> {}}: let
  fsleyes = pkgs.callPackage ./fsleyes.nix {inherit pkgs;};
in
  pkgs.mkShell {
    buildInputs = [
      (pkgs.python3.withPackages (ps: [
        fsleyes
      ]))
    ];
  }

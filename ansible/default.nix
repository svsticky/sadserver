{
  sources ? import ./nix/sources.nix {},
}:

let
  pkgs = import sources.nixpkgs {};
  pkgs-new = import sources.nixpkgs-unstable {};

  python = pkgs.python37;

  ansible-mitogen = import ./nix/ansible-mitogen.nix {inherit python;};

  pythonEnvironment = python.withPackages (pkgs: [
    pkgs.ansible
    pkgs.black
    pkgs.click
    pkgs.mypy
    pkgs.GitPython
    pkgs.ansible-lint
    ansible-mitogen
  ]);

in pkgs.buildEnv {
  name = "sadserver-environment";
  paths = [
    pythonEnvironment
    pkgs-new.bitwarden-cli
    pkgs.jq
    pkgs.yamllint
  ];
}

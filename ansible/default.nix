{
  sources ? import ./nix/sources.nix {},
}:

let
  pkgs = import sources.nixpkgs {};

  python = pkgs.python39;

  ansible-mitogen = import ./nix/ansible-mitogen.nix {inherit python;};

  pythonEnvironment = python.withPackages (pkgs: [
    pkgs.black
    pkgs.click
    pkgs.mypy
    pkgs.GitPython
    pkgs.requests
    ansible-mitogen
  ]);

in pkgs.buildEnv {
  name = "sadserver-environment";
  paths = [
    pythonEnvironment
    pkgs.ansible_2_10
    pkgs.bitwarden-cli
    pkgs.ansible-lint
    pkgs.jq
    pkgs.yamllint
    pkgs.niv
  ];
}

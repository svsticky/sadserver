{
  sources ? import ./nix/sources.nix {},
}:

let
  pkgs = import sources.nixpkgs {};

  python = pkgs.python37;

  ansible-mitogen = import ./nix/ansible-mitogen.nix {inherit python;};

  pythonEnvironment = python.withPackages (pkgs: [
    pkgs.ansible
    pkgs.black
    pkgs.click
    pkgs.mypy
    ansible-mitogen
  ]);

in pkgs.buildEnv {
  name = "sadserver-environment";
  paths = [
    pythonEnvironment
    pkgs.bitwarden-cli
    pkgs.jq
    pkgs.yamllint
  ];
}

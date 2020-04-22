{
  pkgs ? import ./nix/pkgs.nix {},
}:

let
  python = pkgs.python37;

  ansible-mitogen = import ./nix/ansible-mitogen.nix {inherit python;};

  pythonEnvironment = python.withPackages (pkgs: [
    pkgs.ansible
    ansible-mitogen
  ]);

in pkgs.buildEnv {
  name = "sadserver-environment";
  paths = [
    pythonEnvironment
    pkgs.bitwarden-cli
  ];
}

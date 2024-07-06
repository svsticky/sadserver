{ sources ? import ./nix/sources.nix {} }:

let
  pkgs = import sources.nixpkgs {};
  python = pkgs.python312;

  pythonEnvironment = python.withPackages (pkgs: with pkgs; [
    black
    click
    mypy
    GitPython
    requests
    types-requests
    pyaml
    types-pyyaml
  ]);

  linuxOnlyTools = if pkgs.stdenv.isLinux then [ pkgs.ansible-lint ] else [];

in pkgs.buildEnv {
  name = "sadserver-environment";
  paths = [
    pythonEnvironment
    pkgs.ansible_2_16
    pkgs.bitwarden-cli
    pkgs.jq
    pkgs.yamllint
    pkgs.niv
  ] ++ linuxOnlyTools;
}

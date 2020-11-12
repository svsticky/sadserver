# This file determines the environment you get when `nix-shell` is run.
# We want this to be the same as when running `nix run -c`, so we add some
# boilerplate:
let
  # Import nixpkgs
  sources = import ./nix/sources.nix {};
  pkgs = import sources.nixpkgs {};

  # Import whatever's in `default.nix`
  env = import ./default.nix {};

# Make a shell that makes that the only build input
in pkgs.mkShell { buildInputs = [ env ]; }

# We can use this file to run shell scripts in the same environment by adding
# the following shebang lines:
#!/usr/bin/env nix-shell
#!nix-shell -i INTERPRETER [relative path to shell.nix]

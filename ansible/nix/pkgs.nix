# This file specifies a fixed version of the "nixpkgs" 'channel', which
# specifies how to build a coherent set of packages.

# To update to a newer version, first pick some commit hash from the
# `nixpgks-unstable` branch at https://github.com/nixos/nixpkgs and place this
# hash in in `commitHash`, then update the downloadHash with the output of:
# nix-prefetch-url --unpack https://github.com/nixos/nixpkgs/archive/HASH.tar.gz

# This file defines a function: it is possible to pass arguments to `nixpkgs`
# to override existing behaviour.
# Functions in Nix take the form `argument: [expression]`, so we do `args:`
# here to make the expression in this file a function:
args:

let
  # Commit hash of some commit in the nixpkgs repository.
  commitHash = "7e07846d99bed4bd7272b1626038e77a78aa36f6";

  # SHA256-hash of the extracted download. See above on how to get this.
  downloadHash = "1dx82cj4pyjv1fdxbfqp0j7bpm869hyjyvnz57zi9pbp20awjzjr";

  # Download instruction: download the file at `url`, name it `name`, and store
  # it in under /nix/store/nixpkgs, if the hash matches.
  downloadedFile = builtins.fetchTarball {
    name = "nixpkgs-${commitHash}";
    url = "https://github.com/nixos/nixpkgs/archive/${commitHash}.tar.gz";
    sha256 = downloadHash;
  };

in import downloadedFile args

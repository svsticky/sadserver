# This file tells Nix how to download the Mitogen plugin for Ansible and
# extract it to a path in the Nix store.
# To update to a newer version, check Mitogen's [download page] to get the new
# version number, then determine the new downloadHash with:
# `nix-prefetch-url --unpack https://[...]/mitogen-VERSION.tar.gz`
#
# [download page]: https://mitogen.networkgenomics.com/ansible_detailed.html

# The expression in this file is also a function: we need to know the Python
# version to use (since we can build this package for multiple Python
# versions), so the function in this file takes this as a (required) argument.
{python}:

let
  mitogenVersion = "0.2.9";
  downloadHash = "1pzrc39mv363b3fcr2y2zhx3zx9l49azz65sl1j4skf4h4fhdj08";

  # This downloads and extracts the Mitogen package, but does not yet tell
  # Python to install this package.
  sourceFile = builtins.fetchTarball {
    name = "mitogen-${mitogenVersion}-source";
    url = "https://networkgenomics.com/try/mitogen-${mitogenVersion}.tar.gz";
    sha256 = downloadHash;
  };

# buildPythonPackage then uses info on the Python interpreter to install the
# package according to setup.py.
# See: https://nixos.org/nixpkgs/manual/#packaging-a-library

in python.pkgs.buildPythonPackage rec {
  # The Python package's name is 'mitogen' (to match with `setup.py`):
  pname = "mitogen";
  version = mitogenVersion;

  # The "source" for the Python package is the extracted tarball downloaded
  # with fetchTarball:
  src = sourceFile;

  # Running the tests fails, but we don't care about that anyway so we disable
  # those:
  doCheck = false;
}

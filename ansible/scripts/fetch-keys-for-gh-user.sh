#!/usr/bin/env bash

## This script is a utility to fetch SSH public keys from a GitHub
## account and add them to the proper directory.
##
## USAGE: fetch-keys-for-gh-user.sh GITHUB_USERNAME

# Unofficial Bash strict mode
set -eEfuo pipefail
IFS=$'\n\t'

# Find the absolute path to the skyblue repository
SKYBLUE_DIR=$(git rev-parse --show-toplevel)

# Check if a GH username was given
if [[ -z "$1" ]]; then
  >&2 echo "USAGE: fetch-keys-for-gh-user.sh GITHUB_USERNAME"
  exit 1
fi

CREDENTIALS_PATH="${SKYBLUE_DIR}/ansible/credentials/ssh/$1.github.pub"
curl --fail "https://github.com/$1.keys" > "${CREDENTIALS_PATH}"

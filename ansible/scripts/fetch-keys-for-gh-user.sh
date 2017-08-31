#!/usr/bin/env bash

## This script is a utility to fetch SSH public keys from a GitHub account and
## add them to the proper directory.
##
## USAGE: fetch-keys-for-gh-user.sh GITHUB_USERNAME

# Unofficial Bash strict mode
set -eEfuo pipefail
IFS=$'\n\t'

# Find the absolute path to the sadserver repository
SADSERVER_DIR="$(git rev-parse --show-toplevel)"

# Check if a GH username was given
if [[ -z "${1+x}" ]]; then
  >&2 echo "USAGE: fetch-keys-for-gh-user.sh GITHUB_USERNAME"
  exit 1
fi

CREDENTIALS_PATH="${SADSERVER_DIR}/ansible/credentials/ssh/${1}.github.pub"
# Temporarily disable halting on errors, to manually catch possible curl errors
set +e
curl --fail "https://github.com/${1}.keys" -o "${CREDENTIALS_PATH}" > \
/dev/null 2>&1

if [[ "${?}" != "0" ]]; then
  echo "Fetching keys failed. Did you enter a correct GitHub username?"
  exit 1
fi
# Re-enable halting on errors
set -e

AMOUNT_OF_KEYS="$(wc -l "${CREDENTIALS_PATH}" | awk '{print $1}')"
echo "${AMOUNT_OF_KEYS} Key(s) fetched successfully for ${1}."

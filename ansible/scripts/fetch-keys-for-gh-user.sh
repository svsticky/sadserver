#!/usr/bin/env bash

## This script is a utility to fetch SSH public keys from GitHub accounts and
## add them to the proper directory.
##
## USAGE: fetch-keys-for-gh-user.sh [GITHUB_USERNAME]...

# Unofficial Bash strict mode
set -eEfuo pipefail
IFS=$'\n\t'

# Find the absolute path to the sadserver repository
SADSERVER_DIR="$(git rev-parse --show-toplevel)"

# Check if a minimum of 1 GH username was given
if [[ -z "${1+x}" ]]; then
  >&2 echo "USAGE: fetch-keys-for-gh-user.sh [GITHUB_USERNAME]..."
  exit 1
fi

for USERNAME in "${@}"; do
  CREDENTIALS_PATH="${SADSERVER_DIR}/ansible/group_vars/ssh_keys/${USERNAME}.github.pub"
  # Temporarily disable halting on errors, to manually catch possible curl
  # errors
  set +e
  curl --fail "https://github.com/${USERNAME}.keys" -o "${CREDENTIALS_PATH}" > \
  /dev/null 2>&1

  if [[ "${?}" != "0" ]]; then
    echo -e "Fetching keys failed. Did you enter a correct GitHub username?\n"
    echo "Be advised that these are case-sensitive."
    exit 1
  fi
  # Re-enable halting on errors
  set -e

  AMOUNT_OF_KEYS="$(grep -c '.*' "${CREDENTIALS_PATH}")"
  if [[ "${AMOUNT_OF_KEYS}" -gt 0 ]]; then
    echo "${AMOUNT_OF_KEYS} Key(s) fetched successfully for ${USERNAME}."
  else
    rm "${CREDENTIALS_PATH}"
    echo "No keys found in GitHub account of ${USERNAME}."
    if [[ "$#" -eq 1 ]]; then
      exit 1
    fi
  fi
done

#!/usr/bin/env bash

##
## USAGE:
## ./scripts/get-vault-pass-from-bitwarden-client.sh --vault-id <vault id>
##
## Dependencies:
##   - Bitwarden CLI
##   - jq
##
## This script uses Bitwarden's CLI tool to print the Ansible Vault passphrase
## for the vault id that is passed as an argument, to stdout. Make sure that
## nothing else is printed to stdout.
##
## NOTE: The filename (minus extension) of this script *HAS* to end with
## "-client". This makes Ansible 2.5+ add the vault id to the invocation of
## this script. (I did not make that up.)
##

# Unofficial Bash strict mode
set -eEfuo pipefail

USAGE="USAGE: $0 --vault-id <vault id>"
if [[ ${1:-} != "--vault-id" || -z ${2:-} ]]; then
  echo "${USAGE}" >&2
  exit 1
fi

VAULT_ID="${2}"

# Pulls changes from the remote BW vault, which should only fail when the vault
# is not unlocked yet. If so, it prints an error message that's more helpful
# than the default one.
bw sync >/dev/null || { echo \
  "ERROR: No unlocked Bitwarden vault encountered in environment." \
  "Please unlock your Bitwarden vault first using \"bw unlock\"." >&2; \
  exit 1; }

echo "Vault passphrase for ${VAULT_ID} environment:" >&2
bw get item caa7fb69-913a-4f08-9d0f-a87f013d39d2 \
  | jq --exit-status --raw-output \
    ".fields[] | select(.name==\"${VAULT_ID}\") | .value" \
  || exit 2
  # Fail with RC of 2 when secret is not found,
  # because Ansible recognises this.

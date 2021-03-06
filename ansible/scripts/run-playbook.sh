#!/usr/bin/env nix-shell
#!nix-shell -i bash ../shell.nix

##
## USAGE: ./scripts/run-playbook.sh <production | staging> <PLAYBOOK_PATH>
## [<ANSIBLE-PLAYBOOK PARAMETERS>]
##
## This is a wrapper script for ansible-playbook, that lets you run playbooks
## on our server.
##
## In addition to running the actual playbook, it posts notifications to Slack
## before and after the playbook has run, indicating what playbook was run,
## from what Git branch + revision, and whether it finished successfully or
## failed.
##

# Unofficial Bash strict mode
set -eEfuo pipefail
# Although in strict mode, space character is not removed from $IFS
# here, because of the spaces in $SLACKTEE

USAGE="USAGE: $0 <production | staging> <PLAYBOOK_PATH> [<ANSIBLE-PLAYBOOK \
PARAMETERS>]"
if [[ -z ${1:-} || -z ${2:-} ]]; then
  echo "$USAGE"
  exit 1
fi

if [ ! -f .slack-webhook ]; then
  echo "Please create .slack-webhook with a webhook URL for deploy notifications"
  exit 1
fi

export SLACKTEE_WEBHOOK=$(cat .slack-webhook)
export ANSIBLE_STDOUT_CALLBACK=yaml

GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
GIT_SECRETS_BRANCH="$(git submodule foreach 'git status')"
GIT_REVISION="$(git rev-parse HEAD)"
GIT_ROOT="$(git rev-parse --show-toplevel)"
ENVIRONMENT="${1}"
ARGS=( "${@:2}" )
SLACKTEE="${GIT_ROOT}/ansible/scripts/slacktee.sh --config \
${GIT_ROOT}/ansible/templates/etc/slacktee.conf --plain-text --username Ansible"

function abort_deploy() {
  echo "ABORTED DEPLOY"
  exit 0
}

export ANSIBLE_VAULT_PASSWORD_FILE="./scripts/bitwarden-vault-pass.py"

case ${ENVIRONMENT} in
  production)
    if [[ ${GIT_SECRETS_BRANCH} != *"origin/master"* ]]; then
      while [[ ${BRANCH_CHOICE:-} != "Y" && ${BRANCH_CHOICE:-} != "n" ]]; do
        read -p "You are deploying to production from a group_vars branch other than \
'master', are you sure? [Y/n]: " \
        BRANCH_CHOICE
      done
      case "${BRANCH_CHOICE}" in
        Y)
          ;;
        *)
          abort_deploy
          ;;
      esac
    fi
    export ANSIBLE_VAULT_IDENTITY=production
    while [[ ${PROD_CHOICE:-} != "Y" && ${PROD_CHOICE:-} != "n" ]]; do
      read -p "DO YOU REALLY PLAN TO DEPLOY TO PRODUCTION? [Y/n]: "\
      PROD_CHOICE
    done
    case "${PROD_CHOICE}" in
      Y)
        ;;
      *)
        abort_deploy
        ;;
    esac
    if [[ ${GIT_BRANCH} != "master" ]]; then
      while [[ ${BRANCH_CHOICE:-} != "Y" && ${BRANCH_CHOICE:-} != "n" ]]; do
        read -p "You are deploying to production from a branch other than \
'master', are you sure? [Y/n]: " \
        BRANCH_CHOICE
      done
      case "${BRANCH_CHOICE}" in
        Y)
          ;;
        *)
          abort_deploy
          ;;
      esac
    fi
    ;;
  staging)
    # Special scenario: When restore-backup.yml is run on staging, it needs to
    # access the production Vault secrets, so this adds the call for that to
    # the environment passed to ansible-playbook
    if [[ ${ARGS[0]} == "playbooks/restore-backup.yml" ]]; then
      export ANSIBLE_VAULT_IDENTITY=staging
      VAULT_ID_AMEND="--vault-id production@prompt" 
    else
      export ANSIBLE_VAULT_IDENTITY=staging
    fi
    ;;
  *)
    echo "$USAGE"
    exit 1
    ;;
esac

# This function sends messages to Slack using `slacktee.sh`
#
# The first argument is the icon to accompany the message with [1]
# The second argument is the message highlight color
# All remaining strings are used in the message.
#
# [1]: https://www.webpagefx.com/tools/emoji-cheat-sheet/
function notify() {
  # ${@:n} means: all arguments except for the first n-1
  echo -e "${@:3}" | ${SLACKTEE} --icon "$1" --attachment "$2" > /dev/null
}

notify \
  ':construction:' \
  '#46c4ff' \
  "*Deployment of playbook \`${ARGS[*]}\` in ${ENVIRONMENT} environment \
started by ${USER}*\n" \
  "_(branch: ${GIT_BRANCH} - revision \"${GIT_REVISION}\")_"

function deploy_end {
  export EXIT=$?
  if [[ "$EXIT" = "0" ]]; then
    notify \
      ':ok_hand:' \
      'good' \
      "*Deployment of playbook \`${ARGS[*]}\` in ${ENVIRONMENT} environment \
successfully completed* \n" \
      "_(branch: ${GIT_BRANCH} - revision \"${GIT_REVISION}\")_"
  else
    notify \
      ':exclamation:' \
      'danger' \
      "*Deployment of playbook \`${ARGS[*]}\` in \
${ENVIRONMENT} environment FAILED!* \n" \
      "_(branch: ${GIT_BRANCH} - revision \"${GIT_REVISION}\")_"
    exit $EXIT
  fi
}

trap deploy_end EXIT

ANSIBLE_SSH_PIPELINING=true \
  ansible-playbook \
  --inventory \
    "${GIT_ROOT}/ansible/hosts" \
  --diff \
  ${VAULT_ID_AMEND:-} \
  --limit="${ENVIRONMENT}" \
  --extra-vars \
    "playbook_revision=${GIT_REVISION}" \
  "${ARGS[@]}"

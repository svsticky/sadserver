#!/usr/bin/env bash

##
## USAGE: ./scripts/run-playbook.sh <production | staging> <PLAYBOOK_PATH> [<ANSIBLE-PLAYBOOK PARAMETERS>]
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

USAGE="USAGE: $0 <production | staging> <PLAYBOOK_PATH> [<ANSIBLE-PLAYBOOK PARAMETERS>]"
if [[ -z ${1+x} ]]; then
  echo $USAGE
  exit 1
fi
if [[ -z ${2+x} ]]; then
  echo $USAGE
  exit 1
fi
GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
GIT_REVISION="$(git rev-parse HEAD)"
GIT_ROOT="$(git rev-parse --show-toplevel)"
ARGS="${@:2}"
SLACKTEE="${GIT_ROOT}/ansible/scripts/slacktee.sh --config ${GIT_ROOT}/ansible/templates/etc/slacktee.conf --plain-text --username Ansible"

TARGET_HOST="dev.svsticky.nl"


case $1 in
  production)
    read -p "DO YOU REALLY PLAN TO DEPLOY TO PRODUCTION? [fidgetspinner/N]:" choice
      case "$choice" in
        fidgetspinner)
          TARGET_HOST="svsticky.nl"
          ;;
        *)
          echo "ABORTED DEPLOY"
          exit 0
          ;;
      esac
    ;;
  staging)
    TARGET_HOST="dev.svsticky.nl"
    ;;
  *)
    echo  $USAGE
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
  # ${@:3} means: all arguments except for the first two
  echo -e "${@:3}" | ${SLACKTEE} --icon $1 --attachment $2 > /dev/null
}

notify \
  ':construction:' \
  '#46c4ff' \
  "*Deployment of playbook \`${ARGS}\` started by ${USER}* \n" \
  "_(branch: ${GIT_BRANCH} - revision \"${GIT_REVISION}\")_"

function deploy_end {
  export EXIT=$?
  if [[ "$EXIT" = "0" ]]; then
    notify \
      ':ok_hand:' \
      'good' \
      "*Deployment of playbook \`${ARGS}\` successfully completed* \n" \
      "_(branch: ${GIT_BRANCH} - revision \"${GIT_REVISION}\")_"
  else
    notify \
      ':exclamation:' \
      'danger' \
      "@it-crowd-commissie *Deployment of playbook \`${ARGS}\` FAILED!* \n" \
      "_(branch: ${GIT_BRANCH} - revision \"${GIT_REVISION}\")_"
    exit $EXIT
  fi
}

trap deploy_end EXIT

ANSIBLE_SSH_PIPELINING=true \
  ansible-playbook \
  --inventory \
  "${GIT_ROOT}/ansible/hosts" \
  --ask-become-pass \
  --ask-vault-pass \
  --limit=${TARGET_HOST} \
  --extra-vars \
  "playbook_revision=${GIT_REVISION}" \
  ${@:2}


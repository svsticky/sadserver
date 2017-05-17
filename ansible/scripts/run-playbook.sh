#!/usr/bin/env bash

##
## USAGE: ./scripts/run-playbook.sh <PLAYBOOK_PATH> [<ANSIBLE-PLAYBOOK PARAMETERS>]
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
set -Efuo pipefail
# Although in strict mode, space character is not removed from $IFS
# here, because of the spaces in $SLACKTEE

GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
GIT_REVISION="$(git rev-parse HEAD)"
GIT_ROOT="$(git rev-parse --show-toplevel)"
PLAYBOOK="$1"
SLACKTEE="${GIT_ROOT}/ansible/scripts/slacktee.sh --config ${GIT_ROOT}/ansible/templates/etc/slacktee.conf --plain-text --username Ansible"

echo -e "*Deployment of playbook \"_${PLAYBOOK}_\" started by ${USER}*\n_(branch: ${GIT_BRANCH} - revision \"${GIT_REVISION}\")_" | ${SLACKTEE} --icon ':construction:' --attachment '#46c4ff' > /dev/null

ANSIBLE_SSH_PIPELINING=true ansible-playbook -i "${GIT_ROOT}/ansible/hosts" --ask-become-pass --ask-vault-pass --extra-vars "playbook_revision=${GIT_REVISION}" "$@"

if [[ "$?" = "0" ]]; then
  echo -e "*Deployment of playbook \"_${PLAYBOOK}_\" successfully completed*\n_(branch: ${GIT_BRANCH} - revision \"${GIT_REVISION}\")_" | ${SLACKTEE} --icon ':ok_hand:' --attachment 'good' > /dev/null
else
  echo -e "@it-crowd-commissie *Deployment of playbook \"_${PLAYBOOK}_\" FAILED!*\n_(branch: ${GIT_BRANCH} - revision \"${GIT_REVISION}\")_" | ${SLACKTEE} --icon ':exclamation:' --attachment 'danger' > /dev/null
fi

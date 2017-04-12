#!/bin/sh

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

# Unofficial Bash strict mode (edited, to work with non-Bash)
set -efu
IFS="$(printf '%b_' '\t\n')"
# Protect trailing \n
IFS="${IFS%_}"

GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
GIT_REVISION="$(git rev-parse HEAD)"
GIT_ROOT="$(git rev-parse --show-toplevel)"
PLAYBOOK="$1"
alias slacktee="slacktee.sh --config '${GIT_ROOT}/ansible/templates/etc/slacktee.conf' --plain-text --username 'Ansible'"

echo "*Deployment of playbook \"_${PLAYBOOK}_\" started by ${USER}*\n_(branch: ${GIT_BRANCH} - revision \"${GIT_REVISION}\")_" | slacktee --icon ':construction:' --attachment '#46c4ff' > /dev/null

ANSIBLE_SSH_PIPELINING=true ansible-playbook -i "${GIT_ROOT}/ansible/hosts" --ask-become-pass --extra-vars "playbook_revision=${GIT_REVISION}" "$@"

if [ "$?" = "0" ]; then
  echo "*Deployment of playbook \"_${PLAYBOOK}_\" successfully completed*\n_(branch: ${GIT_BRANCH} - revision \"${GIT_REVISION}\")_" | slacktee --icon ':ok_hand:' --attachment 'good' > /dev/null
else
  echo "@it-crowd-commissie *Deployment of playbook \"_${PLAYBOOK}_\" FAILED!*\n_(branch: ${GIT_BRANCH} - revision \"${GIT_REVISION}\")_" | slacktee --icon ':exclamation:' --attachment 'danger' > /dev/null
fi

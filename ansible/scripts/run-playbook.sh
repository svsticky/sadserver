#!/bin/sh

GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
GIT_REVISION="$(git rev-parse HEAD)"
GIT_ROOT="$(git rev-parse --show-toplevel)"
alias slacktee="slacktee.sh --config '${GIT_ROOT}/ansible/templates/etc/slacktee.conf' --plain-text --username 'Ansible'"

echo "*Deployment of playbook \"_$1_\" started by ${USER}*\n_(branch: ${GIT_BRANCH} - revision \"${GIT_REVISION}\")_" | slacktee --icon ':construction:' --attachment '#46c4ff' > /dev/null

ANSIBLE_SSH_PIPELINING=true ansible-playbook -i "${GIT_ROOT}/ansible/hosts" --ask-become-pass --extra-vars "playbook_revision=${GIT_REVISION}" "$@"

if [ "$?" = "0" ]; then
  echo "*Deployment of playbook \"_$1_\" successfully completed*\n_(branch: ${GIT_BRANCH} - revision \"${GIT_REVISION}\")_" | slacktee --icon ':ok_hand:' --attachment 'good' > /dev/null
else
  echo "*Deployment of playbook \"_$1_\" FAILED!*\n_(branch: ${GIT_BRANCH} - revision \"${GIT_REVISION}\")_" | slacktee --icon ':exclamation:' --attachment 'danger' > /dev/null
fi

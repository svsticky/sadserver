#!/bin/bash
set -e
ANSIBLE_SSH_PIPELINING=true ansible-playbook -i hosts --ask-become-pass $@

#!/bin/bash
set -e
ansible-playbook -i hosts --ask-sudo-pass $@

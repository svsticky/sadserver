#!/bin/bash
# Adapted from https://stackoverflow.com/a/22763407 to store in /etc
set -e
apt-get -qq update
apt-get -qq install python-minimal
touch /etc/.ansible_ready

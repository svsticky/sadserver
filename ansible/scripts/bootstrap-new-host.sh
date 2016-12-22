#!/bin/sh

##
## USAGE: ./scripts/bootstrap-new-host.sh <HOSTNAME | IP>
##
## This bootstrap script sets up a vanilla Ubuntu 16.04 image, so that it can
## run our ansible playbooks.
##
## It contains the absolute bare minimum to get a host up and running. Before
## adding new features to this script, consider if it is possible to add these
## to the playbook itself.
##

set -e

display_error() {
  echo >&2 $1
}

# Check if $1, which is the first argument of our script
# is empty/not set
if [ -z "${1+set}" ]; then
  display_error "usage: ./bootstrap.sh <HOSTNAME | IP>"
  exit 1
fi

# SSH specifications for the different users
SSH_HOST=$1
SSH_SPEC=root@${SSH_HOST}

# Password that will be set for the ansible user
PASSWORD=$(openssl rand -base64 15)

echo "==> Bootstrapping host '${1}'"

echo "==> Installing Python 2.7"
ssh -T $SSH_SPEC > /dev/null << EOC
DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends python2.7
EOC

echo "==> Creating ansible user"
ssh -T $SSH_SPEC > /dev/null << EOC
useradd -m -d /home/ansible -s /bin/bash ansible -G sudo
echo "ansible:${PASSWORD}" | chpasswd
EOC

echo "==> Copying root ssh keys to ansible user"
ssh -T $SSH_SPEC > /dev/null << EOC
cp -r /root/.ssh /home/ansible/
chown ansible:ansible -R /home/ansible/.ssh
EOC

echo "==> Sucessfully bootstrapped host"

cat << EOM

Now edit the hosts file to contain ${SSH_HOST} and run the main playbook
by executing:

  ansible-playbook -i hosts main.yml --ask-become-pass

It will attempt to run the main playbook under the ansible user we've just
created. The user ansible has the password ${PASSWORD}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@ ADD THE PASSWORD ABOVE TO THE IT-CROWD PASSWORD MANAGER @@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
EOM

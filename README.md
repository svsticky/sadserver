```
 _____ _   ____   _______ _     _   _ _____
/  ___| | / /\ \ / / ___ \ |   | | | |  ___|
\ `--.| |/ /  \ V /| |_/ / |   | | | | |__
 `--. \    \   \ / | ___ \ |   | | | |  __|
/\__/ / |\  \  | | | |_/ / |___| |_| | |___
\____/\_| \_/  \_/ \____/\_____/\___/\____/
```

# Server workspace

This repository contains Ansible playbooks and relevant documentation for the
IT infrastructure at Study Association Sticky.

For help and questions, contact the relevant committee -- at the time of
writing, this is the [IT Crowd](mailto:helloit@svsticky.nl).

Godspeed!

## Dependencies

The code/scripts in this repository depends on the following software:

 - Ansible ~> 2.1
 - Any POSIX compatible shell

## Ansible playbook

The `ansible/` directory in this repository contains Ansible playbooks, which
are a runnable specification of commands that should be executed when
configuring a Linux system.

The ansible directory contains three important files:

 - `ansible/scripts/bootstrap-new-host.sh` -- an `sh` script that can be used
   to bootstrap a vanilla Ubuntu 16.04 system so that it's ready to run our
   main playbook. Run with your favourite shell.
 - `hosts` -- an [Ansible inventory file][inventory] file which contains a
   specification of all of our hosts.
 - `ansible/main.yml` -- the main playbook. It can be run with the command
   `ansible-playbook -i hosts main.yml`.

  [inventory]:https://docs.ansible.com/ansible/intro_inventory.html


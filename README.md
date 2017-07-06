```
                       888
                       888
                       888
.d8888b   8888b.   .d88888 .d8888b   .d88b.  888d888 888  888  .d88b.  888d888
88K          "88b d88" 888 88K      d8P  Y8b 888P"   888  888 d8P  Y8b 888P"
"Y8888b. .d888888 888  888 "Y8888b. 88888888 888     Y88  88P 88888888 888
     X88 888  888 Y88b 888      X88 Y8b.     888      Y8bd8P  Y8b.     888
 88888P' "Y888888  "Y88888  88888P'  "Y8888  888       Y88P    "Y8888  888
```

# Server workspace

This repository contains Ansible playbooks and relevant documentation for the
IT infrastructure at Study Association Sticky.

For help and questions, contact the relevant committee -- at the time of
writing, this is the [IT Crowd].

Godspeed!

## Dependencies

The code/scripts in this repository depends on the following software:

 - Ansible ~> 2.2
 - [slacktee] (no config necessary)
 - bash

## Ansible playbook

The `ansible/` directory in this repository contains Ansible playbooks, which
are a runnable specification of commands that should be executed when
configuring a Linux system.

The ansible directory contains four important files:

 - `ansible/scripts/bootstrap-new-host.sh` -- an `sh` script that can be used
   to bootstrap a vanilla Ubuntu 16.04 system so that it's ready to run our
   main playbook. Run with your favourite shell.
 - `ansible/hosts` -- an [Ansible inventory file][inventory] file which
    contains a specification of all of our hosts.
 - `ansible/main.yml` -- the main playbook. It can be run with the command
   `ansible/scripts/run-playbook.sh <ENVIRONMENT> main.yml`.
 - `ansible/scripts/run-playbook.sh` -- the `sh` script that should be used to run
    playbooks on our hosts. Posts progress notifications to our Slack channel.

  [IT Crowd]:mailto:itcrowd@svsticky.nl
  [inventory]:https://docs.ansible.com/ansible/intro_inventory.html
  [slacktee]:https://github.com/course-hero/slacktee

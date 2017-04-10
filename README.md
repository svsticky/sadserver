```
   .d8888b.  888               888      888
  d88P  Y88b 888               888      888
  Y88b.      888               888      888
   "Y888b.   888  888 888  888 88888b.  888 888  888  .d88b.
      "Y88b. 888 .88P 888  888 888 "88b 888 888  888 d8P  Y8b
        "888 888888K  888  888 888  888 888 888  888 88888888
  Y88b  d88P 888 "88b Y88b 888 888 d88P 888 Y88b 888 Y8b.
   "Y8888P"  888  888  "Y88888 88888P"  888  "Y88888  "Y8888
                           888
                      Y8b d88P     -- Made with Vim
                       "Y88P"
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
 - Any POSIX compatible shell

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
   `ansible-playbook -i hosts main.yml`.
 - `ansible/scripts/run-playbook.sh` -- the `sh` script that should be used to run
    playbooks on our hosts. Posts progress notifications to our Slack channel.

  [IT Crowd]:mailto:helloit@svsticky.nl
  [inventory]:https://docs.ansible.com/ansible/intro_inventory.html
  [slacktee]:https://github.com/course-hero/slacktee

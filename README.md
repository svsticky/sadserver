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
IT infrastructure at Study Association Sticky. The name of this repository, and
the association's production server, is a reference to [this][sadserver] Twitter
account.

In this README, we try to give some reasons as to why the project is organised
the way it is. Don't try to reinvent the wheel, but feel free to periodically
reconsider the way things are done!

Quick links:

 1. [Updating SSH keys][ssh-keys]
 1. [Deployment guide][deployment-guide]
 1. [Other documentation][docs]

## Reasons for the current approach to Sticky's server management

It was important for this committee to make Sticky's infrastructure easy to
convey to new members of this committee. This is so important, because the
composition of committees often changes a lot from year to year, and at least
some of the infrastructure is critical for the association to function. After a
lot of discussion, we decided to use *configuration management* to set up the
current server, which replaced the previous "snowflake" *skyblue*. Because of
experiences present in the committee, Ansible was chosen to do the trick. This
makes it possible to script everything that is needed for a clean OS-imaged
server to become Sticky's production server.

## Structure of repository

### Dependencies

The code in this repository depends on the following software:

 - [ansible] >= 2.4
 - [slacktee] (no config necessary)
 - bash

Furthermore, the Ansible playbooks assume a **vanilla Ubuntu 18.04 host** to be
deployed on.

### Ansible playbooks

The `ansible/` directory in this repository contains Ansible
playbooks, which are a runnable specification of commands that should be
executed when configuring a Linux system.

You might notice this project doesn't follow all of Ansible's guidelines
regarding the structure of (a set of) playbooks. This is partially so,
because it would add some complexity that doesn't have many benefits when your
infrastructure consists of only one or two servers.

#### Main playbook

There is one main playbook, `ansible/main.yml`, that includes many files that
consist of tasks. This is the playbook that sets up an entire server that hosts
all the applications Sticky self-hosts. This playbook is completely idempotent,
which means it can be run multiple times on the same server without any
unintended consequences. You can't deploy this playbook on a host without
[bootstrapping] it first. Our other playbooks are stored in
`ansible/playbooks/`. These are more specific and consist of not necessarily
idempotent tasks. These are used to e.g. create a new admin user in Koala, and
to restart Koala or nginx.

#### Templates

Templates that have to be parsed and copied to the host, reside in the
`ansible/templates` directory. That directory follows the hierarchy of the root
filesystem on the host, so a template that has to be placed in `/home/koala` on
the host resides in `ansible/templates/home/koala` in the repository. The file
names should also be the same as their target name where possible. For more
information look at our [Ansible styleguide].

#### Variables

All variables we use are stored in a separate repository, [sadserver-secrets],
because these include encrypted secrets. This repository is referenced as a
submodule in `ansible/group_vars/`, and an example of this structure can be
found in [ansible/group_vars_example/]. This folder utilizes a subfolder for
each inventory group, in addition to the general `all`. The appropriate folders
are automatically loaded by Ansible when running a playbook. In these folders
are listed:

- The Linux users, either admins or committees
([ansible/group_vars/all/users.yml])
  - The SSH keys that can be used to SSH in with these accounts
- The websites we host ([ansible/group_vars/all/websites.yml])
- Application-specific variables
(`ansible/group_vars/all|production|staging/vars.yml`)

##### Secrets

Our secrets are stored in `ansible/group_vars/all|production|staging/vault.yml`,
per environment. These files are all encrypted using [Ansible Vault]. These
secrets should all be cycled when someone's access to the corresponding
passphrase is revoked.

### Documentation

In `docs/` you can find all documentation that has been written about this
project, apart from this README, as well as styleguides and templates.

## Setting up the staging and production environment

There is currently one server, `sadserver.svsticky.nl`, used in production, and
one server, `dev.svsticky.nl`, used as a staging server. The staging server
enables the administrators to test changes (to either the infrastructure or
specific applications) in an environment that mimics the production environment
as much as possible, while existing completely independent of the production
environment. Ansible uses an [inventory file][inventory] to list all hosts,
which is kept in this repository in `ansible/hosts`.

To make a host ready to run regular Ansible playbooks on, a special playbook
should be used that bootstraps the server. It installs Ansible's dependencies,
and sets up a non-root user for Ansible to use. A playbook should be applied to
a host by means of a wrapper script around `ansible-playbook`, that posts
progress notifications to the committee's Slack team, among a few other things.

After the bootstrapping, the main playbook can be run to completely set up the
server. The main playbook can be applied in the same way as the bootstrap
playbook.

When this has successfully finished, a server exists that matches one of the
environments.

### Step-by-step guide
These are the steps to follow to set up a new development or production server.
Some of the steps require you to specify which of the two you are setting up.

If you want to migrate from an existing server, a few additional tasks should be
performed, which are explained in detail in [this guide][deployment-new-production].

##### On Digital Ocean:
1. Create a droplet named either `dev.svsticky.nl` (staging) or `svsticky.nl` (production).
1. Assign a floating IP to the new droplet. Floating IP's are already in DNS, which avoids DNS cache problems.


##### On your local terminal:
1. Download the repository and enter the folder.
`$ git clone https://github.com/svsticky/sadserver`
`$ cd sadserver`

1. Update the submodule and enter the ansible folder.
`$ git submodule update --init`
`$ cd ansible`

1. Bootstrap the host for either production or staging.
`$ ./scripts/run-playbook.sh (production|staging) bootstrap-new-host.yml`
You do not need to enter a SUDO password, but you do need to enter the correct Vault password.
At the end of the process you will receive a newly generated SUDO password, which you will need in the next step.

1. Run the main playbook for either production or staging.
`$ ./scripts/run-playbook.sh (production|staging) main.yml`
Enter the password from the previous step when prompted for.


1. To create a new database and start Koala, you will also need to run these two playbooks.
`$ ./scripts/run-playbook.sh (production|staging) playbooks/koala/db-setup.yml`
`$ ./scripts/run-playbook.sh (production|staging) playbooks/koala/start.yml`


## Contact

For help and questions, contact the relevant committee -- at the time of
writing, this is the [IT Crowd].

Godspeed!

  [ssh-keys]:./docs/updating-ssh-keys.md
  [docs]:./docs
  [sadserver]:https://twitter.com/sadserver
  [bootstrapping]:#how-to-set-up-the-staging-and-production-environment
  [Ansible styleguide]:docs/ansible-styleguide.md
  [sadserver-secrets]:../../../sadserver-secrets
  [ansible/group_vars_example/]:ansible/group_vars_example/
  [ansible/group_vars/all/users.yml]:ansible/group_vars_example/all/users.yml
  [ansible/group_vars/all/websites.yml]:ansible/group_vars_example/all/websites.yml
  [Ansible Vault]:http://docs.ansible.com/ansible/playbooks_vault.html
  [inventory]:https://docs.ansible.com/ansible/intro_inventory.html
  [slacktee]:https://github.com/course-hero/slacktee
  [ansible]:https://github.com/ansible/ansible
  [deployment-new-production]:docs/deployment-new-production.md
  [IT Crowd]:mailto:itcrowd@svsticky.nl
  [deployment-guide]:#setting-up-the-staging-and-production-environment


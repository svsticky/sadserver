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

## Reasons for the current approach to Sticky's server management

There are a few reasons we chose for this approach, to manage Sticky's
infrastructure. Historically, this was done by the one or two board members who
possessed the relevant experience, regarding Linux and/or server management.
Some domain-specific knowledge would be transfered from board to board, so this
approach to Sticky's server management could be maintained. This approach
worked, since there was an environment in place, which wouldn't be touched too
much, as to not potentially break existing applications that were used in
production.

During the start of the 10th board of Sticky, halfway through 2015, it became
apparent that there wasn't a sufficient baseline present to transfer the
knowledge needed for the management of Sticky's infrastructure.  The idea arose
of a committee that would be responsible for the management of Sticky's
infrastructure, basically its IT Operations team: *The IT Crowd*. This enabled
the board to delegate this task to a committee, that co-exists with the CommIT.
It was important for this committee to make Sticky's infrastructure easy to
convey to new members of this committee. This is so important, because the
composition of committees often changes a lot from year to year, and at least
some of the infrastructure is critical for the association to function. After a
lot of discussion, we decided to use *configuration management* to set up a new
server, which has replaced the previous "snowflake" *skyblue*. Because of
experiences present in the committee, Ansible was chosen to do the trick. This
makes it possible to script everything that is needed for a clean OS-imaged
server to become Sticky's production server.

## Structure of repository

### Dependencies

The code in this repository depends on the following software:

 - Ansible >= 2.4
 - [slacktee] (no config necessary)
 - bash

Furthermore, the Ansible playbooks assume a **vanilla Ubuntu 16.04 host** to be
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
unintended consequences. Our other playbooks are stored in `ansible/playbooks/`.
These are more specific and consist of not necessarily idempotent tasks. These
are used to e.g. create a new admin user in Koala, and to restart Koala or
nginx.

#### Templates

Templates that have to be parsed and copied to the host, reside in the
`ansible/templates` directory. That directory follows the hierarchy of the root
filesystem on the host, so a template that has to be placed in `/home/koala` on
the host resides in `ansible/templates/home/koala` in the repository. The file
names should also be the same as their target name where possible. For more
information look at our [Ansible styleguide].

#### Variables

All variables we use, except for secrets, are stored in `ansible/vars.yml`. This
variable file is included in the main playbook, and most of the other playbooks.
In that file are listed, among other things:

- The Linux users, either admins or committees
  - The SSH keys that can be used to SSH in with these accounts
- The websites we host
- Application-specific variables

It might be worth splitting this file up, giving users and/or websites their
own file, if more variables get added to the file.

##### Secrets

Our secrets are stored in [ansible/credentials/], per environment. The secrets
that are shared between environments (because of third-party constraints), reside in
[ansible/credentials/shared.yml]. These files are all encrypted using [Ansible
Vault]. These secrets should all be cycled when someone's access to the
corresponding passphrase is revoked.

### Documentation

In `docs/` you can find all documentation that has been written about this
project, apart from this README, as well as styleguides and templates.

## How to set up the staging and production environment

There is currently one server, `sadserver.svsticky.nl`, used in production, and
one server, `dev.svsticky.nl`, used as a staging server. The staging server
enables the administrators to test changes (to either the infrastructure or
specific applications) in an environment that mimics the production environment
as much as possible, while existing completely independent of the production
environment. Ansible uses an [inventory file][inventory] to list all hosts,
which is kept in this repository in `ansible/hosts`.

To make a host ready to run the main Ansible playbooks on, a small shell script
should be used that bootstraps the server. It installs Ansible's dependencies,
and sets up a non-root user that Ansible can use. This should be run as follows:
`$ ansible/scripts/bootstrap-new-host.sh <HOST>`, where `<HOST>` should be
substituted by the DNS name of the vanilla server.

After the bootstrapping, the main playbook can be run to completely set up the
server. A playbook should be applied to a host by means of a wrapper script
around `ansible-playbook`, that posts progress notifications to the committee's Slack
team, among a few other things. To continue setting up a new server, the script
should be run as follows:
`$ ansible/scripts/run-playbook.sh <ENVIRONMENT> main.yml`, where
`<ENVIRONMENT>` should be substituted by either `production` or `staging`.

When this has successfully finished, a server exists that matches one of the
environments. When migrating the production server, a few more tasks should be
performed, which is explained in detail in [this guide][deployment-new-production].

## Contact

For help and questions, contact the relevant committee -- at the time of
writing, this is the [IT Crowd]. When you are reading this, these people are
probably your fellow committee members.

Godspeed!

  [sadserver]:https://twitter.com/sadserver
  [Ansible styleguide]:docs/ansible-styleguide.md
  [ansible/credentials/]:ansible/credentials
  [ansible/credentials/shared.yml]:ansible/credentials/shared.yml
  [Ansible Vault]:http://docs.ansible.com/ansible/playbooks_vault.html
  [inventory]:https://docs.ansible.com/ansible/intro_inventory.html
  [slacktee]:https://github.com/course-hero/slacktee
  [deployment-new-production]:docs/deployment-new-production.md
  [IT Crowd]:mailto:itcrowd@svsticky.nl

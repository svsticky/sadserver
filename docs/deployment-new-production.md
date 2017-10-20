# Checklist new server release

This guide details the steps needed to get a new production environment up and
running.

**Create a new droplet** on DigitalOcean named `svsticky.nl`. The name is
important: it ensures [reverse DNS] lookups for the droplet IP receive the
correct values.

**Stop Koala** on the old production environment.

```bash
# On your local machine, whilst in sadserver/ansible
$ ./scripts/run-playbook.sh production playbooks/koala/stop.yml
```

**Export the databases** that are relevant to the new server:

```bash
$ ssh <user>@svsticky.nl

# Dump all databases to a file databases.sql
$ sudo mysqldump --databases dgdarc indievelopment koala studytrip svsticky > \
databases.sql

$ exit

# Download databases.sql to the current working directory on your local machine
$ scp <user>@svsticky.nl:~/databases.sql .
```

**Redirect requests for ACME challenges** from the old server to the new server.
This allows us to prove ownership of the domains we need to request TLS
certificates for, during the deployment of the new server.

**Bootstrap the new production server**

```bash
# On your local machine, whilst in sadserver/ansible
$ scripts/run-playbook.sh production bootstrap-new-host.yml
```

**Run the playbook** on the new production server

```bash
# On your local machine, whilst in sadserver/ansible
$ ./scripts/run-playbook.sh production main.yml
```

**Copy over the old databases**.

```bash
$ scp databases.sql <user>@svsticky.nl:~/databases.sql
$ ssh user@svsticky.nl
$ sudo mysql < databases.sql
```

**Start koala on the new server**

```bash
# On your local machine, whilst in sadserver/ansible
$ ./scripts/run-playbook.sh production \
playbooks/koala/maintenance-off.yml
```

**Migrate the websites** The following is not part of the playbook and needs to
be done manually:

 - Sticky's WordPress site - here be dragons
 - RADIO
 - Symposium
 - Indievelopment
 - Stichting
 - Wintersport
 - Studiereis
 - DGDARC

**Update the DNS zones** at DigitalOcean of all of Sticky's domains with the IP
addresses of the new droplet. These are the following:

 - dgdarc.com
 - dgdarc.nl
 - execut.nl
 - indievelopment.nl
 - indiedevelopment.nl
 - savadaba.nl
 - sodi.nl
 - stichtingsticky.nl
 - stickyutrecht.nl
 - studieverenigingsticky.nl
 - svsticky.nl

**Wait for the DNS propagation**

After these steps, everything is migrated, and the services should be available
from the same URL's as before. Koala will experience downtime from the moment
its service has been stopped on the old server, until it has been started on
the new server and the changes to the DNS zones have propagated.

After this has all finished, we can point another DNS name in the new DNS zone
to the old server (e.g. `old.svsticky.nl`), to keep it available for a while as
backup. We should update the site names in its webserver accordingly, and
disable Koala entirely, so users don't enter data when they arrive there because
of DNS caching.

 [reverse DNS]:https://en.wikipedia.org/wiki/Reverse_DNS_lookup

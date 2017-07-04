# Checklist new server release

This guide details the steps needed to get a new production environment up and
running.

**Create a new droplet** on DigitalOcean named `svsticky.nl`. The name is
important: it ensures [reverse DNS] lookups for the droplet IP give the correct
values.

**Re-create the DNS zones** of all of Sticky's domains at DigitalOcean with the
IP address of the new droplet. DigitalOcean is currently not the authorative
nameserver for the domains, so no traffic will change. These are the following:

 - dgdarc.com
 - dgdarc.nl
 - indievelopment.nl
 - indiedevelopment.nl
 - savadaba.nl
 - sodi.nl
 - stichtingsticky.nl
 - stickyutrecht.nl
 - studieverenigingsticky.nl
 - svsticky.nl

**Stop Koala** on the old production environment.

```bash
$ ssh <user>@svsticky.nl
$ sudo service unicorn stop
$ exit
```

**Export the databases** that are relevant to the new server:

```bash
$ ssh <user>@svsticky.nl

# Dump all databases to a file databases.sql, you will be prompted for the
# mysql root password
$ mysqldump --user root --password --databases dgdarc indievelopment koala \
  svsticky > databases.sql

$ exit

# Download databases.sql to the current working directory on your local machine
$ scp <user>@svsticky.nl:~/databases.sql .
```

**Change the authorative nameservers** of all domains to DigitalOcean.

**Wait for the DNS propagation**

**Bootstrap the new production server**

```bash
# On your local machine, whilst in skyblue/ansible
$ ./scripts/bootstrap-new-host.sh svsticky.nl
```

**Run the playbook** on the new production server

```bash
# On your local machine, whilst in skyblue/ansible
$ ./scripts/run-playbook.sh main.yml production
```

**Copy over the old databases**. You can find the database password in
Lastpass.

```bash
$ scp databases.sql <user>@svsticky.nl:~/databases.sql
$ ssh user@svsticky.nl
$ mysql -u root -p < databases.sql
```

**Start koala on the new server**

```bash
# On your local machine, whilst in skyblue/ansible
$ ./scripts/run-playbook.sh playbooks/oneoff-koala-maintenance-off.yml production
```

**Migrate the websites** The following is not part of the playbook and needs to
be done manually:

 - Sticky's WordPress site - here be dragons
 - Symposium
 - Indievelopment
 - Stichting
 - Wintersport
 - Studiereis
 - DGDARC

After these steps, everything is migrated, and the services should be available
from the same URL's as before. Koala will experience downtime from the moment
its service has been stopped on the old server, until it has eventually been
started on the new server.

After this has all finished, we can point another DNS name in the new DNS zone
to the old server (e.g. `old.svsticky.nl`), to keep it available for a while
as backup. We should update the site names in its webserver accordingly, and
disable Koala entirely, so users don't enter data when they arrive there because
of DNS caching.

 [reverse DNS]:https://en.wikipedia.org/wiki/Reverse_DNS_lookup

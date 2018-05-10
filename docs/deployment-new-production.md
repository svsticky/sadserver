# Checklist new server release

This guide details the steps needed to get a new production environment up and
running.

**Create a new droplet** on DigitalOcean named `svsticky.nl`. The name is
important: it ensures [reverse DNS] lookups for the droplet IP receive the
correct values.

**Stop Koala** on the old production environment:

```bash
# On your local machine, whilst in sadserver/ansible
$ ./scripts/run-playbook.sh production playbooks/koala/stop.yml
```

**Run backups** of the data that should be migrated to the new server:

<!-- The backup script should be changed to take multiple sources -->
```bash
$ ssh <user>@svsticky.nl
$ for SOURCE in admins databases websites; do
> sudo backup-to-s3.sh ${SOURCE}
> done
$ exit
```

**Redirect requests for ACME challenges** from the old server to the new server.
This allows us to prove ownership of the domains we need to request TLS
certificates for, during the deployment of the new server. This is possible by
changing the [relevant location
block](../ansible/templates/etc/nginx/sites-available/default.conf.j2#L20) in
the nginx configuration to the following (where `<new_IP>` should be changed to
the IP address of the new server):

```
location /.well-known/acme-challenge {
  return 302 http://<new_IP>$request_uri;
}
```

**Temporarily update your inventory** with the IP address of the new production
server (where <new_IP> should be substituted by the new IP address):

```
# On your local machine, whilst in sadserver/ansible
sed -i 's/^svsticky.nl/<new_IP>/' hosts
```

**Bootstrap** the new production server:

```bash
# On your local machine, whilst in sadserver/ansible
$ scripts/run-playbook.sh production bootstrap-new-host.yml
```

**Run the playbook** on the new production server:

```bash
# On your local machine, whilst in sadserver/ansible
$ ./scripts/run-playbook.sh production main.yml
```

**Restore the backups** that were made earlier:

```
# On your local machine, whilst in sadserver/ansible
$ scripts/run-playbook.sh production playbook/restore-backup.yml \
--vault-id production@prompt
```

**Start koala on the new server:**

```bash
# On your local machine, whilst in sadserver/ansible
$ ./scripts/run-playbook.sh production \
playbooks/koala/maintenance-off.yml
```

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

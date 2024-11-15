# Server migration guide

This guide details the steps needed to get a new production environment up and
running.

**Create a new droplet** on [DigitalOcean]. Select the desired OS and region.
Be sure to enable IPv6, and add the keys of all IT Crowd members. Name the
droplet `svsticky.nl`. The name is important: it ensures [reverse DNS] lookups
for the droplet IP receive the correct values. Also create two temporary DNS
records that point `(*.)new-prod.svsticky.nl` to the new IP.

Then, do `cd ansible`.

**Stop Koala** on the old production environment:

```bash
# On your local machine, whilst in sadserver/ansible
$ ./deploy.py --host=production --playbook playbooks/koala/maintenance-on.yml
```

**Run backups** of the data that should be migrated to the new server:

```bash
# On your local machine, whilst in sadserver/ansible
$ ./deploy.py --host=production --playbook playbooks/create-backup.yml
```

> Note that the hostnames should NOT be changed during backup. Make sure
> these are set up correctly

This script will ask you what to make a backup off. Enter all fields possible.
(e.g. `admins,websites,postgres,contentful`). Be aware that the backup process
may take about 15 minutes.

**Redirect requests for ACME challenges** from the old server to the new server.
This allows us to prove ownership of the domains we need to request TLS
certificates for, during the deployment of the new server. This is possible by
changing the [relevant location
block](../ansible/templates/etc/nginx/sites-available/default.conf.j2#L20) in
the nginx configuration to the following:

```
location /.well-known/acme-challenge {
  return 302 http://new-prod.svsticky.nl$request_uri;
}
```

**Temporarily update your inventory** with the IP of the new production server,
because this is not changed in DNS yet (replace the IP by the actual new IP):

```bash
# On your local machine, whilst in sadserver/ansible
$ sed -i '/^svsticky\.nl / s/$/ ansible_host=192.0.2.0/' hosts
```

**Bootstrap** the new production server:

```bash
# On your local machine, whilst in sadserver/ansible
$ ./deploy.py --host=production --playbook playbooks/bootstrap-new-host.yml
```

**Run the playbook** on the new production server:

```bash
# On your local machine, whilst in sadserver/ansible
$ ./deploy.py --host=production
```

**Restore the backups** that were made earlier:

```bash
# On your local machine, whilst in sadserver/ansible
$ ./deploy.py --host=production --playbook playbooks/restore-backup.yml
```

**Re-run the playbook** on the new production server, because the backup might
have restored out-of-date system state:

```bash
# On your local machine, whilst in sadserver/ansible
$ ./deploy.py --host=production
```

**Start Koala on the new server:**

```bash
# On your local machine, whilst in sadserver/ansible
$ ./deploy.py --host=production --playbook playbooks/koala/maintenance-off.yml
```

**Update the DNS zones** at DigitalOcean of all of Sticky's domains with the IP
addresses of the new droplet. These are the following:

 - dgdarc.com
 - dgdarc.nl
 - indievelopment.nl
 - intro-cs.nl
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

After this has all finished, we can delete the temporary DNS record on
`new-prod.svsticky.nl` and we can point another DNS name to the old server
(e.g. `old.svsticky.nl`), to keep it available for a while as backup. **Be sure
to disable at least all of the custom systemd timers on the old production
server that use external services.** Otherwise they might interfere with the
new production environment. This includes the backup timers and Certbot's timer.

 [reverse DNS]:https://en.wikipedia.org/wiki/Reverse_DNS_lookup
 [DigitalOcean]:https://cloud.digitalocean.com/dashboard

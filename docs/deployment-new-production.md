# Guide for the deployment to a new production environment

When deploying the playbook in a new production environment, some steps need to
be taken to get everything up and running.

1. Create the server, e.g. by creating a droplet on DigitalOcean. Make sure its
   rDNS, which at DigitalOcean is coupled to the droplet name, is set to
   `svsticky.nl`.
2. Point the DNS name from the *staging* inventory to the server, and reflect
   this in Ansible's inventory. Also, the DNS zones of all of Sticky's domains
   should be present at DO (although DO isn't the authoritative nameserver yet
   for these domains at this point).
3. After checking the DNS has propagated, run the entire playbook on the new
   server, having selected the staging inventory.
4. Copy the TLS certificates of all websites that should be migrated to the
   new server, retaining the directory structure of Certbot.
5. Stop the Koala instance in the current production environment.
6. Export the database of Koala and all other websites that should be migrated
   to the new server.
7. *Import all these databases on the newly created server.*
8. *Import the contents of all websites to the new server, by cloning from git
   or by transferring the contents from the old server.*
9. Start Koala on the new server.
10. In the playbook, make sure no domains are commented out in `vars.yml` and
    the `--staging` parameter is not present in the certbot task.
11. Change the authoritative nameservers of all of Sticky's domains from
    TransIP to DigitalOcean.
12. After checking the DNS has propagated, run the playbook again, but now
    having selected the production inventory. This makes sure the actually
    trusted TLS certificates will be requested.

After these steps, everything is migrated, and the services should be available
from the same URL's as before. Koala will experience downtime during the moment
that point 4 has finished, but point 10 has not. Other services should not
experience any downtime.

The italic points in the list would benefit from additions, like one-offs, to
the [current](../../../tree/c886badbcebfd7b7a49a05c466e91dc2663262e2) version of
the playbook.

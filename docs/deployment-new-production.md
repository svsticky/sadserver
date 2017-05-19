# Guide for the deployment to a new production environment

When deploying the playbook in a new production environment, some steps need to
be taken to get everything up and running.

1. Create the server, e.g. by creating a droplet on DigitalOcean. Make sure its
   rDNS, which at DigitalOcean is coupled to the droplet name, is set to
   `svsticky.nl`.
1. Re-create the DNS zones of all of Sticky's domains at DO (although DO isn't
   the authoritative nameserver yet for these domains at this point).
1. Stop the Koala instance in the current production environment.
1. Export the database of Koala and and the databases and/or contents of all
   other websites that should be migrated to the new server.
1. Change the nameservers of all domains to DigitalOcean.
1. After checking the DNS has propagated, run the entire playbook on the new
   server, having selected the production inventory. Also run the necessary 
   one-offs.
1. Import all these databases on the newly created server.
1. Start Koala on the new server.
1. Import the contents of all websites for which it is necessary to the new
   server, by cloning from git or by transferring the contents from the old
   server.

After these steps, everything is migrated, and the services should be available
from the same URL's as before. Koala will experience downtime from the moment
that point 3 has finished, other services from the moment point 5 has finished.

After this has all finished, we can point another DNS name in the new DNS zone
to the old server, to keep it available for a while as backup. We should update
the site names in its webserver accordingly, and perhaps disable Koala entirely,
so people don't enter data there unknowingly.

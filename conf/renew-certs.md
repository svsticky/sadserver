# renew-certs.sh

Het script dat in de crontab staat van `root` en wekelijks wordt gedraaid op het moment.
	
	#/bin/bash

	/opt/letsencrypt/letsencrypt-auto certonly -a webroot --keep-until-expiring --agree-tos --email itcrowd@stickyutrecht.nl --webroot-path /var/www/dgdarc/dgdarc.nl --domains dgdarc.nl,www.dgdarc.nl,dgdarc.com,www.dgdarc.com,dgdarc.stickyutrecht.nl
	/opt/letsencrypt/letsencrypt-auto certonly -a webroot --keep-until-expiring --agree-tos --email itcrowd@stickyutrecht.nl --webroot-path /var/www/indievelopment/indievelopment.nl --domains indievelopment.nl,www.indievelopment.nl,indievelopment.stichtingsticky.nl
	/opt/letsencrypt/letsencrypt-auto certonly -a webroot --keep-until-expiring --agree-tos --email itcrowd@stickyutrecht.nl --webroot-path /var/www/sodi.nl --domains sodi.nl,www.sodi.nl
	/opt/letsencrypt/letsencrypt-auto certonly -a webroot --keep-until-expiring --agree-tos --email itcrowd@stickyutrecht.nl --webroot-path /var/www/stichting/stichtingsticky.nl --domains stichtingsticky.nl,www.stichtingsticky.nl
	/opt/letsencrypt/letsencrypt-auto certonly -a webroot --keep-until-expiring --agree-tos --email itcrowd@stickyutrecht.nl --webroot-path /var/www/symposium/darksideof.it --domains darksideof.it,www.darksideof.it,darksideofit.stickyutrecht.nl
	/usr/sbin/nginx -s reload


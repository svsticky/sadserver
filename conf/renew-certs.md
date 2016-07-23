# renew-certs.sh

Het script dat in de crontab staat van `root` en wekelijks wordt gedraaid op het moment.

	#/bin/bash

	/opt/certbot/certbot-auto certonly --non-interactive --no-self-upgrade --keep-until-expiring --agree-tos --email itcrowd@svsticky.nl -a webroot --webroot-path /var/www/svsticky.nl --domains svsticky.nl,www.svsticky.nl,stickyutrecht.nl,www.stickyutrecht.nl
	/opt/certbot/certbot-auto certonly --non-interactive --no-self-upgrade --keep-until-expiring --agree-tos --email itcrowd@svsticky.nl -a webroot --webroot-path /var/www/koala.svsticky.nl/public --domains koala.svsticky.nl,koala.stickyutrecht.nl,intro.svsticky.nl,intro.stickyutrecht.nl
	/opt/certbot/certbot-auto certonly --non-interactive --no-self-upgrade --keep-until-expiring --agree-tos --email itcrowd@svsticky.nl -a webroot --webroot-path /var/www/betalingen.svsticky.nl --domains betalingen.svsticky.nl
	/opt/certbot/certbot-auto certonly --non-interactive --no-self-upgrade --keep-until-expiring --agree-tos --email itcrowd@svsticky.nl -a webroot --webroot-path /var/www/dgdarc/dgdarc.nl --domains dgdarc.nl,www.dgdarc.nl,dgdarc.com,www.dgdarc.com,dgdarc.svsticky.nl,dgdarc.stickyutrecht.nl
	/opt/certbot/certbot-auto certonly --non-interactive --no-self-upgrade --keep-until-expiring --agree-tos --email itcrowd@svsticky.nl -a webroot --webroot-path /var/www/digidecs.svsticky.nl --domains digidecs.svsticky.nl,digidecs.stickyutrecht.nl
	/opt/certbot/certbot-auto certonly --non-interactive --no-self-upgrade --keep-until-expiring --agree-tos --email itcrowd@svsticky.nl -a webroot --webroot-path /var/www/indievelopment/indievelopment.nl --domains indievelopment.nl,www.indievelopment.nl,indievelopment.stichtingsticky.nl
	/opt/certbot/certbot-auto certonly --non-interactive --no-self-upgrade --keep-until-expiring --agree-tos --email itcrowd@svsticky.nl -a webroot --webroot-path /usr/share/pma --domains phpmyadmin.svsticky.nl,phpmyadmin.stickyutrecht.nl
	/opt/certbot/certbot-auto certonly --non-interactive --no-self-upgrade --keep-until-expiring --agree-tos --email itcrowd@svsticky.nl -a webroot --webroot-path /var/www/commit/radio.svsticky.nl --domains radio.svsticky.nl,radio.stickyutrecht.nl
	/opt/certbot/certbot-auto certonly --non-interactive --no-self-upgrade --keep-until-expiring --agree-tos --email itcrowd@svsticky.nl -a webroot --webroot-path /var/www/kb/redesign.svsticky.nl --domains redesign.svsticky.nl
	/opt/certbot/certbot-auto certonly --non-interactive --no-self-upgrade --keep-until-expiring --agree-tos --email itcrowd@svsticky.nl -a webroot --webroot-path /var/www/sodi/sodi.nl --domains sodi.nl,www.sodi.nl
	/opt/certbot/certbot-auto certonly --non-interactive --no-self-upgrade --keep-until-expiring --agree-tos --email itcrowd@svsticky.nl -a webroot --webroot-path /var/www/stichting/stichtingsticky.nl --domains stichtingsticky.nl,www.stichtingsticky.nl
	/opt/certbot/certbot-auto certonly --non-interactive --no-self-upgrade --keep-until-expiring --agree-tos --email itcrowd@svsticky.nl -a webroot --webroot-path /var/www/studiereis/studytrip.svsticky.nl/public_html --domains studytrip.svsticky.nl,studiereis.svsticky.nl,studytrip.stickyutrecht.nl,studiereis.stickyutrecht.nl --webroot-path /var/www/studiereis/studytrip.svsticky.nl/committee --domains studiereiscommissie.svsticky.nl,studiereiscommissie.stickyutrecht.nl
	/opt/certbot/certbot-auto certonly --non-interactive --no-self-upgrade --keep-until-expiring --agree-tos --email itcrowd@svsticky.nl -a webroot --webroot-path /var/www/symposium/darksideof.it --domains darksideof.it,www.darksideof.it
	/opt/certbot/certbot-auto certonly --non-interactive --no-self-upgrade --keep-until-expiring --agree-tos --email itcrowd@svsticky.nl -a webroot --webroot-path /var/www/wintersport/wintersport.svsticky.nl --domains wintersport.svsticky.nl,swarovski.svsticky.nl,wintersport.stickyutrecht.nl,swarovski.stickyutrecht.nl
	/usr/sbin/nginx -s reload

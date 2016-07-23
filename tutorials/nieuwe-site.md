# Nieuwe site aanmaken

Indien een commissie een website nodig heeft, is dit een stappenplan wat in de huidige situatie gevolgd zou moeten worden.

1. Maak een beperkte gebruiker aan (zie [hier](nieuwe-gebruiker.md)).
2. Maak een webroot aan voor de site.
   1. `# mkdir /var/www/<USERNAME>/example.svsticky.nl/`
   2. `# chown <USERNAME>:www-data /var/www/<USERNAME>/example.svsticky.nl/`
   3. `# chmod g+rwxs /var/www/<USERNAME>/example.svsticky.nl/`
3. Zorg voor een SSL-certificaat voor de site (zie [hier](letsencrypt.md)). 
   1. Gebruik echter de eerste keer dat je een certificaat wil genereren de authenticatiemethode `standalone` i.p.v. `webroot`, omdat nginx nog geen configuratie voor de site heeft op dit moment.
   2. Dit doe je met de volgende commando's.
      1. Stop tijdelijk nginx: `# nginx -s stop`
      2. Genereer het certificaat: `# /opt/certbot/certbot-auto certonly --non-interactive --no-self-upgrade --keep-until-expiring --agree-tos --email itcrowd@svsticky.nl -a standalone --domains <DOMAIN1,DOMAIN2>`
      3. Start nginx weer: `# nginx`
4. Maak een configuratie in nginx aan voor de site.
   1. Pak één van de [templates](../conf/nginx.md) en zet de hostname(s) op de goede plekken.
   2. Sla de configuratie op in `/etc/nginx/sites-available`.
   3. Indien de configuratie gedeployed kan worden: `# ln -s /etc/nginx/sites-available/example.svsticky.nl /etc/nginx/sites-enabled/example.svsticky.nl`.
4. Laat nginx gebruik maken van de nieuwe configuratie.
   1. Laat de nieuwe configuratie checken qua syntax door nginx: `# nginx -t`. 
   2. Indien de configuratie ok is, start nginx dan opnieuw op om de wijziging door te voeren: `# nginx -s reload`. 

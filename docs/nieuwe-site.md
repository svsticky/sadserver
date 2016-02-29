# Nieuwe site aanmaken

Indien een commissie een website nodig heeft, is dit een stappenplan wat in de huidige situatie gevolgd zou moeten worden.

1. Maak een beperkte gebruiker aan (zie [hier](ssh.md)).
2. Maak een webroot aan voor de site.
   1. `# mkdir /var/www/<USERNAME>/example.svsticky.nl/`
   2. `# chown <USERNAME>:www-data /var/www/<USERNAME>/example.svsticky.nl/`
   3. `# chmod g+rwxs /var/www/<USERNAME>/example.svsticky.nl/`
3. Zorg voor een SSL-certificaat voor de site (zie [hier](letsencrypt.md)).
4. Maak een configuratie in nginx aan voor de site.
   1. Pak één van de [templates](../conf/nginx.md) en zet de hostname(s) op de goede plekken.
   2. Sla de configuratie op in `/etc/nginx/sites-available`.
   3. Indien de configuratie gedeployed kan worden: `# ln -s /etc/nginx/sites-available/example.svsticky.nl /etc/nginx/sites-enabled/example.svsticky.nl`.
4. Start nginx opnieuw op om de wijziging door te voeren: `# nginx -s reload`. 

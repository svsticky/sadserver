# Let's Encrypt

Op het moment zijn alle sites die gehost worden op de server voorzien van een SSL-certificaat, afgezien van `infozuil.svsticky.nl` (wegens legacy incompatibilities). Ook is er nog een certificaat aanwezig van *TransIP*, dat nog geldig is tot 6 september 2016. Deze is echter niet meer in gebruik, omdat alle sites maken gebruik van SSL-certificaten van *Let's Encrypt*. Deze certificaten hebben de voorkeur, omdat deze gratis zijn en automatisch vernieuwd kunnen worden, in tegenstelling tot het certificaat van TransIP. De certificaten uitgegeven door Let's Encrypt zijn echter wel maar 90 dagen geldig en er zijn geen wildcard-certificaten te krijgen. Om geldige certificaten te blijven gebruiken, wordt er wekelijks door middel van een cronjob gecontroleerd of er certificaten vernieuwd moeten worden.

## Client

Sticky gebruikt de standaard [Let's Encrypt ACME client](https://github.com/letsencrypt/letsencrypt). De enige dependency hiervoor is Python 2.6-2.7. De handigste manier om de client aan te roepen is via de bijgeleverde wrapper `letsencrypt-auto`. Dit moet als root, omdat er een tijdelijke webserver wordt opgezet tijdens de authenticatie voor het domein.

De client staat momenteel geïnstalleerd in `/opt/letsencrypt/`, met haar configuratie in `/etc/letsencrypt/`. In de laatstgenoemde map bevindt zich ook het script (*[renew-certs.sh](../conf/renew-certs.md)*) dat wekelijks door cron wordt aangeroepen, om te checken of er certificaten vernieuwd moeten worden.

## Certificaat installeren voor nieuwe site

De wrapper wordt aangeroepen met de volgende parameters:

* `certonly` We gebruiken geen plugin om de webserverconfiguratie aan te passen, dus er moet alleen een certificaat gegenereerd worden.
* `-a webroot` We gebruiken de webroot als authenticatiemethode voor het domein waar we een site voor aan willen vragen. Dit betekent dat er tijdelijk een aantal bestanden in onderstaande webroot worden geplaatst en opgevraagd.
* `--webroot-path /var/www/example.tld` De bijbehorende webroot.
* `--keep-until-expiring` Dit geeft aan dat er pas een nieuw certificaat moet worden gegenereerd als er geen bestaand certificaat is dat nog 'nieuw' (<30 dagen oud) is.
* `--agree-tos` Hiermee gaan we akkoord met de licentievoorwaarden van Let's Encrypt.
* `--email itcrowd@svsticky.nl` Het e-mailadres dat in het certificaat komt te staan.

* `--domains example.tld,www.example.tld,example.svsticky.nl` De domeinen waar het certificaat geldig voor moet zijn, met een voorbeeld. Wildcards zijn niet mogelijk.

Dit ziet er dan dus zo uit in het script:

`/usr/local/src/letsencrypt/letsencrypt-auto certonly -a webroot --keep-until-expiring --agree-tos --email itcrowd@svsticky.nl --webroot-path /var/www/example.tld --domains example.tld,www.example.tld,example.svsticky.nl`

Het certificaat wordt vervolgens, als alles goed gaat, gegenereerd en opgeslagen in `/etc/letsencrypt/live/example.tld/`. Nginx heeft de versie van het certificaat nodig met het intermediate certificate in de chain, dat is `fullchain.pem`, en uiteraard de private key, in `privkey.pem`. Aan de configuratie in nginx van de betreffende site moeten vervolgens dan ook de volgende regels worden toegevoegd:

	ssl_certificate /etc/letsencrypt/live/example.tld/fullchain.pem;
	ssl_certificate_key /etc/letsencrypt/live/example.tld/privkey.pem;

Ook is nu mogelijk, en aan te raden, om de site te voorzien van [HSTS](https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security) (HTTP Strict Transport Security). Dit kan door onderstaande directive nog toe te voegen:

	add_header Strict-Transport-Security "max-age=31536000; includeSubdomains";

Vergeet na het toevoegen de webserver niet opnieuw op te starten, waarna het nieuwe certificaat geserveerd zal worden.

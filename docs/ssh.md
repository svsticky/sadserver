# SSH-gegevens voor `skyblue`

Root login staat uit, net zoals password login. Je hebt keys nodig.

## Hostnames

 - `skyblue.svsticky.nl`
 - `vps40506.public.cloudvps.com`

## Beschikbare gebruikers

### Administrators

 - admin (wordt gebruikt door het bestuurslid in de IT Crowd)
 - arian
 - laurens
 - martijn
 - tom

Alle bovengenoemde gebruikers hebben sudo-rechten. Indien er nieuwe leden plaatsnemen in de IT Crowd en een gebruiker op de server tot hun beschikking krijgen, krijgen zij mogelijk niet direct sudo-rechten. Aan een procedure hiervoor wordt op dit moment gewerkt.

### Beperkte gebruikers

 - commit
 - dgdarc
 - indievelopment
 - sodi
 - stichting
 - studiereis
 - symposium
 - wintersport

Naast de bestuursleden en IT Crowd-leden die volledige toegang hebben tot de server, moeten ook bepaalde andere personen binnen de vereniging de server soms kunnen gebruiken. Dit gaat doorgaans om commissieleden die een project, zoals een site, moeten bijhouden voor Sticky. Denk aan de CommIT, maar ook wintersport/studiereis etc.

Hierbij is belangrijk dat deze laatste groep gebruikers beperkt moet worden in hun toegang tot de server. Deze beperkte gebruikers hebben alleen toegang tot hun eigen data, en niet tot de rest van de server. Dit wordt bereikt door middel van een jail (chroot).

#### Aanmaken nieuwe beperkte gebruiker

In `/etc/ssh/sshd_config` staat geconfigureerd dat gebruikers die deel uitmaken van de groep `privileged`, alleen SFTP-toegang hebben en geen shell-toegang. Ook zijn deze gebruikers chrooted in hun homedirectory. Omdat deze gebruikers doorgaans toegang tot de server moeten hebben voor een webapplicatie, staan hun homedirectories in `/var/www/`. Binnen deze homedirectory dient dan een submap als webroot voor de webserver. In de configuratie van de host in de webserver moet dan ook `/var/www/<USERNAME>/<HOSTNAME>` als webroot ingesteld worden.

Op de volgende manier kan de beperkte gebruiker aangemaakt worden:

```
# adduser --home=/var/www/<USERNAME> --disabled-password <USERNAME>
# adduser <USERNAME> privileged
# chown root:<USERNAME> /var/www/<USERNAME>/
```
Vergeet de keys van de bevoegde personen niet toe te voegen aan `<HOMEDIR>/.ssh/authorized_keys`.

# Beperkte gebruikers

Naast de bestuursleden en IT Crowd-leden die volledige toegang hebben tot de server, moeten ook bepaalde andere personen binnen de vereniging de server soms kunnen gebruiken. Dit gaat doorgaans om commissieleden die een project, zoals een site, moeten bijhouden voor Sticky. Denk aan de CommIT, maar ook wintersport/studiereis etc.

Hierbij is belangrijk dat deze laatste groep gebruikers beperkt moet worden in hun toegang tot de server. Deze beperkte gebruikers hebben alleen toegang tot hun eigen data, en niet tot de rest van de server. Dit wordt bereikt door middel van een jail (chroot).

## Aanmaken nieuwe beperkte gebruiker

In `/etc/ssh/sshd_config` staat geconfigureerd dat gebruikers die deel uitmaken van de groep `privileged`, alleen SFTP-toegang hebben en geen shell-toegang. Ook zijn deze gebruikers chrooted in hun homedirectory. Omdat deze gebruikers doorgaans toegang tot de server moeten hebben voor een webapplicatie, staan hun homedirectories in `/var/www/`. Binnen deze homedirectory dient dan een submap als webroot voor de webserver. In de configuratie van de host in de webserver moet dan ook `/var/www/<USERNAME>/<HOSTNAME>` als webroot ingesteld worden.

Het volgende stappenplan kan gebruikt worden om dit te bewerkstelligen:

```sh
# adduser --home=/var/www/<USERNAME> --disabled-password <USERNAME>
# adduser <USERNAME> privileged
# chown root:testuser /var/www/<USERNAME>/
```
Inloggen is alleen mogelijk met een SSH-key, dus vergeet de keys van de bevoegde personen niet toe te voegen aan `<HOMEDIR>/.ssh/authorized_keys`.

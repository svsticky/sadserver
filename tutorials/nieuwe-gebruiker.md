# Aanmaken nieuwe beperkte gebruiker

In `/etc/ssh/sshd_config` staat geconfigureerd dat gebruikers die deel uitmaken van de groep `privileged`, alleen SFTP-toegang hebben en geen shell-toegang. Ook zijn deze gebruikers chrooted in hun homedirectory. Omdat deze gebruikers doorgaans toegang tot de server moeten hebben voor een webapplicatie, staan hun homedirectories in `/var/www/`. Binnen deze homedirectory dient dan een submap als webroot voor de webserver. In de configuratie van de host in de webserver moet dan ook `/var/www/<USERNAME>/<HOSTNAME>` als webroot ingesteld worden.

Op de volgende manier kan de beperkte gebruiker aangemaakt worden:

```
# adduser --home=/var/www/<USERNAME> --disabled-password <USERNAME>
# adduser <USERNAME> privileged
# chown root:<USERNAME> /var/www/<USERNAME>/
```
Vergeet de keys van de bevoegde personen niet toe te voegen aan `<HOMEDIR>/.ssh/authorized_keys`.

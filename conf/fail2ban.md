fail2ban
========

fail2ban is een programma wat logfiles scant op zoek naar gefaalde authenticatiepogingen. Als het programma ziet dat er van hetzelfde IP-adres een hele hoop requests komen, dan worden tijdelijk firewallregels toegevoegd die dit IP blokkeren.

Configuratie is te vinden in `/etc/fail2ban/jail.conf`, maar `skyblue` draait de standaardconfiguratie en kijkt alleen naar SSH-verzoeken.

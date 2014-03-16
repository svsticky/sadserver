Logrotate op `purple`
=====================

Logrotatatie is het splitsen van logfiles in kleine stukken, en het uiteindelijke weggooien van oude logfiles, aangezien deze aanzienlijk veel schijfruimte in kunnen nemen.

Configuration files
-------------------

`/etc/logrotate.conf` specificeert de generieke opties voor de rotatie van logfiles. Het bestand leest ook alle bestanden uit `/etc/logrotate.d` uit, waar applicaties hun eigen logfiles in kunnen specificeren. De inhoud is standaard voor Debian 7, behalve dat de `compress` directive aan staat.

Invocation
----------

Logrotate moet handmatig uitgevoerd worden in de volgende vorm: `logrotate /etc/logrotate.conf`. Dit wordt gedaan in `/etc/cron.daily/logrotate`.

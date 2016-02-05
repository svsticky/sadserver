`skyblue`
========

Deze VPS draait meerdere websites en heeft alles overgenomen van de oude server in de kelder sinds de zomer van 2014. De IT Crowd heeft de server in beheer, maar ook de CommIT heeft beperkt toegang tot sommige sites. Daarnaast heeft de CommIT een team op GitHub waarbij ze meerdere projecten kunnen aanpassen. Hierna kan de IT Crowd de laatste dingen testen en op de server pullen. Controle over de VPS kan via SSH en via een controlepaneel van CloudVPS.

System specifications
---------------------

| Wat            | Toelichting         |
| -------------- | ------------------: |
| OS             | Ubuntu 14.04.3 LTS  |
| Disk space     | 20GB                |
| RAM            | 1024MB              |
| Transfer/month | 1TB                 |

IP-adres
----------

 - `89.31.97.186`

SSL-certificaten
---------------

TransIP beheert onze domeinnamen en beheert momenteel ook het wildcard-certificaat voor `*.stickyutrecht.nl`. Deze moet jaarlijks tegen betaling verlengd worden, en het nieuwe certificaat kan eenvoudig in gebruik genomen worden door een paar nieuwe bestanden te kopiëren nadat er een certificate signing request is uitgevoerd. 

Daarnaast worden de overige domeinnamen in beheer (zie onder) voorzien van SSL-certificaten van Let's Encrypt. Deze certificaten zijn gratis, maar wel maar 90 dagen geldig. Hierbij zijn geen wildcard-certificaten te krijgen. Er draait elke 2 maanden een cronjob op de server die al deze certificaten verlengt.

In de toekomst zal waarschijnlijk ook het wildcard-certificaat voor `*.stickyutrecht.nl` vervangen worden door één of meerdere certificaten uitgegeven door Let's Encrypt.

Admins
------

 - Arian van Putten (`aeroboy94@gmail.com`)
 - Laurens Duijvesteijn (`l.duijvesteijn@gmail.com`)
 - Martijn Casteel (`martijn.casteel@gmail.com`)
 - Tom Wassenberg (`itcrowd@tomwassenberg.nl`)

Daemons
-------

 - SSH
 - nginx
 - MongoDB
 - Ruby

Production services
-------------------

 - `www.stickyutrecht.nl`
 - `digidecs.stickyutrecht.nl`


 - `studiereis.stickyutrecht.nl`
 - `wintersport.stickyutrecht.nl`


 - `koala.stickyutrecht.nl`
 - `betalingen.stickyutrecht.nl`
 - `phpmyadmin.stickyutrecht.nl`


 - `infozuil.stickyutrecht.nl`
 - `radio.stickyutrecht.nl`


 - `darksideof.it`
 - `dgdarc.nl`
 - `indievelopment.nl`
 - `sodi.nl`
 - `stichtingsticky.nl`

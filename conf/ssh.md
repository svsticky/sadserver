# SSH-gegevens voor `skyblue`

Root login staat uit, net zoals password login. Je hebt keys nodig.

## Beschikbare gebruikers

### Administrators

- _admin (wordt momenteel gebruikt door Bas de Kan en na de bestuurswissel in september uitgefaseerd)_
- arian
- laurens
- maarten
- _martijn (wordt binnenkort verwijderd)_
- tom
- yorick

Alle bovengenoemde gebruikers hebben sudo-rechten.

### Beperkte gebruikers

 - commit
 - dgdarc
 - indievelopment
 - kb
 - sodi
 - stichting
 - studiereis
 - symposium
 - wintersport

Naast de bestuursleden en IT Crowd-leden die volledige toegang hebben tot de server, moeten ook bepaalde andere personen binnen de vereniging de server soms kunnen gebruiken. Dit gaat doorgaans om commissieleden die een project, zoals een site, moeten bijhouden voor Sticky. Denk aan de CommIT, maar ook wintersport/studiereis etc.

Hierbij is belangrijk dat deze laatste groep gebruikers beperkt moet worden in hun toegang tot de server. Deze beperkte gebruikers hebben alleen toegang tot hun eigen data, en niet tot de rest van de server. Dit wordt bereikt door middel van een jail (chroot).

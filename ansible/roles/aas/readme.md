# Aas

[Aas] is a webhook listener, that we use to catch various webhooks.

The primary use case it to deploy new versions of our public website, static-sticky.
The website builds in GitHub actions, and when that succeeds, it is uploaded to S3, and a webhook is thrown to Aas.
Aas then runs a script that fetches the latest build from S3 and deploys it.
For more details see the [static-sticky] repository and role.

The seconds current use case of Aas is to catch a webhook from our introduction Pretix ticket site.
The data is sent by Aas to A-Eskwadraat, which apparently needs this data for their introduction.
This project is affectionately called Privacyschender-3000.

Aas is build in CI with Nix, uploaded to Cachix, and fetched by the `nix-store --realize` command.

[Aas]:https://github.com/svsticky/aas
[static-sticky]:https://github.com/svsticky/static-sticky

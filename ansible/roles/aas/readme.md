# Aas

[Aas] is a webhook listener, that we use to catch various webhooks.

The primary use case it to deploy new versions of our public websites, static-sticky and intro-website.
The website builds in GitHub actions, and when that succeeds, it is uploaded to S3 or to GitHub as an artifact, and a webhook is thrown to Aas.
Aas then runs a script that fetches the latest build from S3 or GitHub and deploys it.
For more details see the [static-sticky] repository and role.

Aas is build in CI with Nix, uploaded to Cachix, and fetched by the `nix-store --realize` command.

[Aas]:https://github.com/svsticky/aas
[static-sticky]:https://github.com/svsticky/static-sticky

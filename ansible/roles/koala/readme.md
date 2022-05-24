# Koala

[Koala] is the core of our associations' application stack.
It functions as the member registration, activity management, features payments
and integrates with multiple external platforms, like Exact online and Mailchimp.

It includes an oauth provider which we use the authenticate users to multiple
applications with.
It also features an API that multiple applications depends on.

[Koala]: https://github.com/svsticky/constipated-koala/

## Dependencies

Koala depends on the following roles:

- `databases`: Koala needs a Postgresql database
- `nix`: Koala runs inside a Nix shell to fetch it dependencies.
- `redis`: Redis is used for Sidekiq, which is the applications queue manager.
- `nginx`: Like all our applications, Koala lives behind a reverse proxy.
- `logrotate`: Koala's logs are rotated by this application.
- `fail2ban`: Fail2ban monitors access to the public Koala API.

## Integrations

Koala depends on multiple external platforms:

- [Mailgun]: Mailgun is used to sends emails with.
- [Sentry]: Runtime errors are reported to Sentry.
- [Mollie]: Mollie is used as our payment provider.
- [Mailchimp]: We sync our members mailing list preferences to Mailchimp.

The credentials of these applications should regularly be cycled in their
respective web interfaces, and simultateous updated in the `.env` file.
Mailchimp also has a host of non-secret variables, which are list and category
identifiers. It is further documented in the [Koala repository](https://github.com/svsticky/constipated-koala/blob/master/MAILCHIMP.md).

[Mailgun]: https://www.mailgun.com/
[Sentry]: https://sentry.io/
[Mollie]: https://www.mollie.com/
[Mailchimp]: https://mailchimp.com/

## One-time commands

Koala has quite a few management commands.
Those should be run as the Koala user, in a Nix shell:

``` bash
sudo -su koala
cd /var/www/koala.svsticky.nl
nix-shell
```

The most used one-time commands are:

- Creating a new admin: `rails admin:create[username, password]`
- Removing an admin: `rails admin:delete[username]`

Listing all existing commands can be done with: `rails`.
Be careful when running one-time commands: make absolutely sure that you know
what you are doing before running the command. Try commands locally and on
staging before running them on production.

If you need to run a command more often, check if you can add it to the playbook.

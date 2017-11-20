# Deploying an upgrade of Koala

Note: this guide assumes only a upgrade of Koala's codebase, when this is asked
for by the CommIT. Changing the nginx config is out of scope, and has to be done
separately if needed.

1. Ensure that the outage is known by at least one person who is not imaginary
   and who is a board member (bestuurslid). Also ensure that the rest of the IT
   Crowd is at least aware of your actions, preferably by announcing it on
   Slack.
1. Ensure that there is a tag at the revision that is to be deployed. Change the
   tag used in `koala.git_ref` in [/ansible/group_vars/production/vars.yml] to
   this new tag, and commit this change.
1. Run the playbook `main.yml`.
1. Verify that you can log in, and that the [API] is responding.

## Reverting non-destructive migrations
When a rollback is needed because of issues, and the problematic upgrade 
included one or more database migrations, these need to be reverted manually.

In order to revert a set number of migrations, the command `bin/rails
db:rollback STEP=$n` can be used. This will revert the effects of the `$n` most
recent migrations, like this:

```bash
$ bin/rails db:migrate:status
 Status   Migration ID    Migration Name
--------------------------------------------------
   up     20160402084056  Add table and stuff
   up     20160506121430  Broken nonsense
   up     20160802082751  Revert me
   up     20160817130851  Dumpster fire

$ bin/rails db:rollback STEP=3
...

$ bin/rails db:migrate:status
 Status   Migration ID    Migration Name
--------------------------------------------------
   up     20160402084056  Add table and stuff
 down     20160506121430  Broken nonsense
 down     20160802082751  Revert me
 down     20160817130851  Dumpster fire
```

Do *not* use `db:migrate:down`, as this will only set a single revision to
`down`, instead of migrating down to the specified version.

[API]: https://koala.svsticky.nl/api/activities
[/ansible/group_vars/production/vars.yml]: https://github.com/svsticky/sadserver-secrets/tree/master/production/vars.yml

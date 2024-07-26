# Outline configuration

The `docker.env` file contains many configurations, but some configurations must
be done through the website itself - the settings page. These settings are
stored in the database, and thus not expressed through the `docker.env` file.

When creating a new database, the following settings must be set through the
website:

- Arbitrary members should be viewers, and admins (board members and such) should
  be editors. Whilst it does not fully match this logic, the default role for
  new members must be set to `viewer` and not `editor`.
- Logging in should only be done through our OAuth provider. Thus, logging in
  through email should be disabled.

## Creating a new database and/or migrating

Outline databases are maintained (and created?) using migrations. When updating
the outline version, one _must_ create a backup beforehand, for the
documentation states that the database will automatically be migrated once the
service starts.

When no database exists yet, this can be created by migrating/seeding.

For both scenarios, I would like to refer you to [the official documentation](https://docs.getoutline.com/s/hosting/doc/docker-7pfeLP5a8t).

## Updating to a newer version

When updating outline to the latest version, please make a backup beforehand!
As explained in the section above, the next time outline starts, a database
migration will automatically occur.

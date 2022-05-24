# Auth

This role manages the ssh keys of admins and some other ssh and authentication configuration.
The goal is that each IT Crowd member has an account, with sudo privileges.
On production using sudo requires entering a password.
A few other users also get ssh access, but without sudo rights (and generally not a lot of rights).

The public ssh keys are fetched from GitHub on deploy time.
This means we can give access to the server to someone by just knowing their GitHub username.
The users and the github account that get access to this users are configured in `groupvars/all/users.yml`.

# How to add a new user to the server (staging/production)

This document explains how you can authenticate someone to access the server, as
admin or normal user.

## Normal user (no admin)

> In general, if someone wants to be of any use in the server, add them as an
> admin.

To add non-privileged user, expand the `users` property in `/ansible/group_vars/all/users.yml`
to include a new user:

```
  - name: "pietjankbal"
    admin: false
    home_prefix: "/home"
    state: "present"
    github_accounts:
      - username: "pietJankbalOnGithub"
        state: "present"
```

## Admin

Similarly to the normal user, you should add the following to the `users`
property in `/ansible/group_vars/all/users.yml`:

```
  - name: "pietjankbal"
    admin: true
    home_prefix: "/home"
    state: "present"
    github_accounts:
      - username: "pietJankbalOnGithub"
        state: "present"
```

Now to Linux, the new user is an admin. To tell Ansible that this user has
the rights to run playbooks, add the following info to the `ansible` user
in the `users` property:

```
  - username: "pietJankbalOnGithub"
    state: "present"
```

Now both Linux and Ansible give you full privileges.

## SSH keys

In general, SSH keys should have been fetched from GitHub. Nothing to do now!
However, I would just like to add that if you want to update ssh keys, please
refer to the other documentation - even if it relates to this.

## Afterwards

The new user can access the server through `ssh svsticky.nl` or `ssh
dev.svsticky.nl`, for production and staging respectively. On production, the
user is prompted to reset his password on first login.

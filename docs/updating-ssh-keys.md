# Updating associated SSH keys

The public parts of all SSH keys that give access to one or more accounts on our
production and/or staging environment reside in [/ansible/group_vars/all/ssh_keys].
The keys can be sourced manually, but most of the times it's the easiest to use
the script that fetches keys from one or more GitHub profiles. This script can
be run as follows: `$ ansible/scripts/fetch-keys-for-gh-user.sh
<GITHUB_USERNAME>...`, where `GITHUB_USERNAME` is substituted for the name of
the person's GitHub account. This saves the keys of each person specified in
a separate file in the correct directory.

If you are adding keys from a new GitHub profile, or sourcing new keyfiles
manually, you have to add the name of this file to the list of keys in the user
dictionary in [/ansible/group_vars/all/users.yml]. Match its "id" to the
filename in [/ansible/group_vars/all/ssh_keys], and be sure to set the state to
"present".

**Remember:** If you want to revoke a key's access, do not simply delete the
file from the list and/or repository, but **first** set its "state" to "absent".
After that, you can delete the entry from the list (and the keyfile from the
repository if it's not used for another user account). If you do not set the
state to "absent" first, the key will **not** be deleted from the server you
deploy on.

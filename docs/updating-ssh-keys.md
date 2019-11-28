# Updating associated SSH keys

If you are adding keys from a new GitHub profile, you have to add the
username to [/ansible/group_vars/all/users.yml].

**Remember:** If you want to revoke a key's access, do not simply delete the
user from the `users.yml`, but **first** set the "state" to
"absent". After that, you can delete the entry from the list. If you do not
set the state to "absent" first, the key will **not** be deleted from the
server you deploy on.

[/ansible/group_vars/all/users.yml]:
http://github.com/svsticky/sadserver-secrets/tree/master/all/users.yml

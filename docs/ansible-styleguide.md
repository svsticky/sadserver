# Ansible Styleguide

This is mostly a summary from [this styleguide][whitecloud/ansible-styleguide].
Don't hesitate to ask any questions if you don't get or disagree with something
here. If you're confused about something because it is underspecified, please
add an example after you figured it out.

## Summary

 1. Start your `.yml` scripts with three dashes (`---`).
 2. End all your `.yml` files with a newline (`\n`).
 3. Always double quote strings. Don't quote integers or booleans (e.g. `42`
    or `true` / `false`).
 4. Only use `true` and `false` for boolean values.
 5. Use one space after the colon in a key/value pair (e.g. `key: value`
    instead of `key : value`).
 6. Always use the map syntax for dictionaries.
 7. When files need to be transferred, use templates.
 7. All templates should have the `ansible_managed` header and the `.j2` file extension.
 8. Use `become` instead of `sudo`.
 9. Blank lines between two blocks and tasks.
 10. `snake_case` for variables.
 11. If you define multiple variables with the same prefix, put them in a map.

## Examples

### Map syntax

Good:

```
- name: "install htop"
  package:
    name: htop
    state: installed
```

Bad:

```
- name: "install htop"
  package: name=htop state=installed
```

## Variables with shared prefix

Good:

```
koala:
  environment: production
  server: unicorn
  git_ref: ansible_test
  ruby_version: 2.3.0
```

Bad:

```
koala_environment: production
koala_server: unicorn
koala_git_ref: ansible_test
koala_ruby_version: 2.3.0
```

 [whitecloud/ansible-styleguide]: https://github.com/whitecloud/ansible-styleguide)`

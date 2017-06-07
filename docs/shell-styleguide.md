# Shell Script Styleguide
These are some guidelines you should probably adhere to when working on shell
scripts in this repository. If you want to deviate from these guidelines, that
is of course fair, as long as you have a good reason. Bonus points if you add
documentation about such deviations in this guide.

## ShellCheck
[ShellCheck] is a linter that gives all kinds of warnings and suggestions
about subtle mistakes you might make regarding quoting, style, typo's and
other [code smells][badcode]. This _will_ help you find bugs.

## Unofficial _Unofficial Bash Strict Mode_
We use the [Unofficial Bash Strict Mode][strictmode], with a few extra
checks. The complete block is added in the checklist below. You should read
the article for a complete explanation, but here is a short summary of
what all commands do:
- `set -e`: Exit script if any command has a non-zero exit status.
- `set -E`: Makes bash traps apply in subshells.
- `set -f`: Disables expanding of glob patterns.
- `set -o pipefail`: If a command that's part of a pipeline fails, this
   makes the whole pipeline return the exit code of that command, instead of
   using the one of the last command in the pipeline.
- `set -u`: Exit when any unset variable is encountered.
- `IFS=$'\n\t'`: Sets the Bash variable for the [Internal Field
Separator][ifs] to just a newline and a tab character, while omitting the
space character. This makes sure that word splitting does not take place on
spaces.

## Use of exit codes
Most shell scripts we have are run non-interactively. This means we want to
get a notification if they fail. We have failure notifications in place
that are sent based on the exit code of a script (if it is ran as part of a
systemd service). Please pay attention to the exit code of your script: Always
exit with a non-zero code in case of failure that the IT Crowd should know
about!

## Cleanup function (optional)
When your script creates files, especially when it's run server-side, it's
wise to make use of a bash trap. This makes it possible to run a command
when the script, for _whatever_ reason, exits. Using a construction like
below makes sure that certain files are always cleaned up afterwards.
```
cleanup() {
  rm -rf <PATH_TO_FILES>
}

trap cleanup EXIT
```

## **Checklist**

1. Use Bash, start with the following shebang: 
   `#!/usr/bin/env bash`.
1. Add some documentation that explains what the script does, including one
line that shows what parameters are accepted and in what order. E.g. `USAGE:
bootstrap-new-host.sh <HOSTNAME | IP>`.
1. For server-side scripts:
   1. Follow it by the Ansible header:
      `# {{ ansible_managed }}`.
   1. Suffix the file name with the `j2` file extension.
1. Add abovementioned Strict Mode to the top of your script, directly
following the shebang and `ansible_managed` header:
   ```
   # Unofficial Bash strict mode
   set -eEfuo pipefail
   IFS=$'\n\t'
   ```
1. Run every edit through the ShellCheck linter, using a plugin in your
   favorite editor or by running:
   `shellcheck <PATH_TO_SCRIPT>`.
1. Use Bash's extended test command, instead of the regular test
construct (e.g. in if statements), because it's less
[error-prone][testcommand]:
   ~~`if [ true ]`~~ `if [[ true ]]`

[ShellCheck]: https://github.com/koalaman/shellcheck
[badcode]: https://github.com/koalaman/shellcheck/blob/master/README.md#gallery-of-bad-code
[strictmode]: http://redsymbol.net/articles/unofficial-bash-strict-mode/
[ifs]: https://en.wikipedia.org/wiki/Internal_field_separator
[testcommand]: https://stackoverflow.com/questions/669452/is-preferable-over-in-bash

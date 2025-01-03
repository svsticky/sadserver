# Pretix

## Maintenance mode

Pretix has a weekly routine in enabling and disabling maintenance mode.
The treasurer benefits from this, for the weekly reports from Mollie have a
different cut-off then Pretix has, which can't be reconfigured. As such, Pretix
will be brought in maintenance mode during this overlapping period, to make the
book works way easier.

Maintenance mode can be manually enabled for an arbitrarily long duration, but
not disabled for an arbitrarily long duration, on purpose. This can be done
with the two playbooks:

```bash
$ sadserver/ansible
./deploy.py --to staging --playbook=playbooks/pretix/lock-maintenance.yml
```

```bash
$ sadserver/ansible
./deploy.py --to staging --playbook=playbooks/pretix/unlock-maintenance.yml
```

### How the maintenance mode works

Maintenance mode is enabled when a marker file is present, indicating it is on.
Nginx will respect this and return a 503 error page, preventing users from
buying tickets. Admin panels and such are still available.

This state is managed with a single script: `/usr/local/bin/pretix-maintenance.sh`.
This script can be run as the systemd service `pretix-maintenance`, which is
automatically run two times every week (at the start and end of the overlapping
reporting period). Taking all things into account, this script ensures the
maintenance mode is in the right state.

If you wish to enable maintenance mode manually - and locking it, preventing
the weekly service from touching the marker file - a playbook is available,
placing a second marker file (lock) and running the same systemd service to
ensure the maintenance mode is in the desired state. Running the other
playbook, this lock file is removed and the systemd script is run again. Note
that when this is done during the overlapping reporting period - when
maintenance mode should be on - the maintenance marker still persists, but the
lock is gone.

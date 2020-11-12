#!/usr/bin/env nix-shell
#!nix-shell -i bash ../shell.nix

## This is a small wrapper script that exposes a local socket you can use to
## login to a remote MariaDB server. You need this, when:
##
##   - the MariaDB account you need to login with (e.g. root) relies on Unix
##     socket authentication, AND
##   - you can SSH in, but not as the user corresponding with the
##     abovementioned MariaDB user, BUT
##   - the account you can SSH in as, *can* use sudo to run commands as the
##     abovementioned Linux user
##
## USAGE: mariadb-root-tunnel.sh [DB_SERVER]

# Unofficial Bash strict mode
set -eEfuo pipefail
IFS=$'\n\t'

# If no other server specified, default to the staging server
DB_SERVER="${1:-dev.svsticky.nl}"

LOCAL_DB_SOCKET="/tmp/${DB_SERVER}_mariadb.sock"
REMOTE_TUNNEL_SOCKET="$(mktemp -u -p /tmp/ --suffix=.sock \
  ${USER}_mariadb.XXXXXXXX)"
REMOTE_DB_SOCKET="/var/run/mysqld/mysqld.sock"
REMOTE_DB_USER="root"

cleanup() {
  # ssh doesn't remove the local socket afterwards, but it will fail the next
  # time if the socket already exists. Therefore we always delete it before
  # exiting.
  rm -f -- "${LOCAL_DB_SOCKET}"
}

trap cleanup EXIT

echo "Enter your sudo password if prompted."
echo -e \
  "Afterwards, you can use the following" \
  "command to connect to the MariaDB server:\n"
echo "mariadb --socket ${LOCAL_DB_SOCKET} --user ${REMOTE_DB_USER}"
ssh \
  -q \
  -t \
  -L "${LOCAL_DB_SOCKET}:${REMOTE_TUNNEL_SOCKET}" \
  "${DB_SERVER}" \
  sudo -u ${REMOTE_DB_USER} \
    socat \
    "UNIX-LISTEN:${REMOTE_TUNNEL_SOCKET},fork,user=\${USER},group=\${USER}" \
    "UNIX-CONNECT:${REMOTE_DB_SOCKET}"

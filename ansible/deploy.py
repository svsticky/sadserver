#!/usr/bin/env nix-shell
#!nix-shell -i python ./shell.nix

import click
import os
import subprocess
import requests
import json

from git.repo import Repo
from typing import Optional

import scripts.bitwarden as bitwarden


@click.command()
@click.option(
    "--host",
    "--to",
    required=True,
    type=click.Choice(["staging", "production"]),
    help="The host to deploy to",
)
@click.option(
    "--playbook",
    default="main.yml",
    type=click.Path(exists=True),
    help="Ansible playbook to run",
)
@click.option("--tags", "--roles", help="Roles to execute")
@click.option("--check", is_flag=True, default=False, help="Perform a dry run")
@click.option("--force", is_flag=True, default=False, help="Override checks")
def deploy(
    host: str, playbook: str, tags: Optional[str], check: bool, force: bool
) -> None:
    bitwarden.unlock()
    if not check and not force:
        verify_on_latest_master(host)

    # Sync bitwarden
    os.system("bw sync")

    # in the original script we doublecheck if production deploy is intended. Should we do that here?

    user = os.environ["USER"]
    branch = current_branch_name()
    revision = current_git_revision()[:8]

    env = os.environ.copy()
    env["ANSIBLE_STDOUT_CALLBACK"] = "yaml"
    env["ANSIBLE_VAULT_IDENTITY"] = host
    env["ANSIBLE_SSH_PIPELINING"] = "true"
    # Used by the bitwarden plugin
    env["STICKY_ENV"] = host

    arguments = [
        "ansible-playbook",
        "--inventory",
        "./hosts",
        "--diff",
        "--limit",
        host,
        "--extra-vars",
        f"playbook_revision={revision}",
    ]

    # Special scenario: When restore-backup.yml is run on staging, it needs to
    # access the production Vault secrets, so this adds the call for that to
    # the environment passed to ansible-playbook
    if playbook == "playbooks/restore-backup.yml":
        # Used by the bitwarden plugin
        env["STICKY_RESTORING_BACKUP"] = "1"

    if check:
        arguments.append("--check")

    if not tags is None:
        arguments.append("--tags")
        arguments.append(tags)

    arguments.append(playbook)

    if not check:
        notify_deploy_start(playbook, host, user, branch, revision)

    print("Running the following playbook:")
    print(" ".join(arguments))

    try:
        subprocess.run(arguments, check=True, env=env)
        if not check:
            notify_deploy_succes(playbook, host, branch, revision)

    except subprocess.CalledProcessError:
        if not check:
            notify_deploy_failure(playbook, host, branch, revision)


def current_branch_name() -> str:
    repo = Repo("..")
    return str(repo.active_branch)


def current_git_revision() -> str:
    repo = Repo("..")
    return str(repo.commit().hexsha)


def notify_deploy_start(
    playbook: str, host: str, user: str, git_branch: str, git_revision: str
) -> None:
    discord_notify(
        f"*Deployment of playbook {playbook} in {host} environment started by {user}*\n"
        + f'_(branch: {git_branch} - revision "{git_revision}")_',
        ":construction:",
        "#46c4ff",
    )


def notify_deploy_succes(
    playbook: str, host: str, git_branch: str, git_revision: str
) -> None:
    discord_notify(
        f"*Deployment of playbook {playbook} in {host} environment succesfully completed*\n"
        + f'_(branch: {git_branch} - revision "{git_revision}")_',
        ":construction:",
        "good",
    )


def notify_deploy_failure(
    playbook: str, host: str, git_branch: str, git_revision: str
) -> None:
    discord_notify(
        f"*Deployment of playbook {playbook} in {host} environment FAILED!*\n"
        + f'_(branch: {git_branch} - revision "{git_revision}")_',
        ":exclamation:",
        "danger",
    )


def discord_notify(message: str, icon: str, color: str) -> None:
    url = get_discord_webhook().strip()

    data = {
        "username": "Ansible",
        "attachments": [
            {
                "color": color,
                "mrkdwn_in": [
                    "text",
                    "fields",
                ],
                "text": message,
            },
        ],
        "icon_emoji": icon,
    }

    r = requests.post(
        url,
        json=data,
    )

    if r.status_code != 200:
        raise click.ClickException(
            f"Discord failed with statuscode {r.status_code} and message {r.text}"
        )


def verify_on_latest_master(host: str) -> None:
    repo = Repo("..")

    # not sure why str() needs to be called
    if host == "production" and str(repo.active_branch) != "master":
        raise click.ClickException(
            "Please do not deploy anything but master to production"
        )

    remote = repo.remotes.origin
    local_commit = repo.commit()
    remote_commit = remote.fetch()[0].commit

    if local_commit.hexsha != remote_commit.hexsha:
        raise click.ClickException(
            "The remote is not on the same commit as your commit"
        )

    # Diff against the working tree
    for x in repo.head.commit.diff(None):
        click.ClickException("There is uncommited in your working tree or staging area")


def get_discord_webhook() -> str:
    webhook_filename = ".discord-webhook"

    if not os.path.exists(webhook_filename):
        raise click.ClickException(
            "Please create .discord-webhook with a webhook URL for deploy notifications"
        )
    else:
        # maybe should be a try-catch block here
        with open(webhook_filename) as f:
            return f.read()


if __name__ == "__main__":
    deploy()

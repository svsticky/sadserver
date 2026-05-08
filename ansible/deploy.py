#!/usr/bin/env nix-shell
#!nix-shell -i python ./shell.nix

import click
import os
import subprocess
import requests
import json
import yaml

from git.repo import Repo
from typing import Optional, List

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
@click.option("--roles", help="Roles to execute")
@click.option("--skip", help="Roles to skip")
@click.option("--check", is_flag=True, default=False, help="Perform a dry run")
@click.option("--force", is_flag=True, default=False, help="Override checks")
@click.option(
    "--from",
    "from_playbook",
    help="Determine from which role to start the deploy from",
)
@click.option(
    "--until", "until_playbook", help="Determine until which role to run the deploy"
)
def deploy(
    host: str,
    playbook: str,
    roles: Optional[str],
    skip: Optional[str],
    check: bool,
    force: bool,
    from_playbook: Optional[str],
    until_playbook: Optional[str],
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
    env["ANSIBLE_VARS_PLUGINS"] = "./plugins/vars"
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

    with open("main.yml", "r") as yaml_file:
        data = yaml.safe_load(yaml_file)

    ### Get the roles list from main.yml
    # This one is to look up things we might remove, ...
    all_role_data = [
        role
        for item in data
        if isinstance(item, dict) and "roles" in item
        for role in item["roles"]
    ]
    # ... we will filter this
    role_data = [it for it in all_role_data]
    all_roles = [it["role"] for it in all_role_data]

    ### Filter out all roles that fall outside specified range
    i = 0
    if from_playbook is not None and from_playbook in all_roles:
        i = all_roles.index(from_playbook)
        role_data = role_data[i:]
    if until_playbook is not None and until_playbook in all_roles:
        # We have to subtract i to correct for offset
        i = all_roles.index(until_playbook) - i
        if i < 0:
            raise IndexError("`--until` role must be after the `--from` role")
        role_data = role_data[: i + 1]

    ### If we didn't specify from or until, clear data
    if from_playbook is None and until_playbook is None:
        role_data = []

    ### Remove roles tagged with never
    # NOTE We don't need to include the "always" roles,
    #      those are built into Ansible
    role_data = list(filter(lambda it: "never" not in it["tags"], role_data))

    ### Include roles from --tags.
    # NOTE We do this after removing the "never" roles,
    #      so if they are specified they do run
    if roles is not None:
        for role in roles.split(","):
            role = role.strip()
            role = next(filter(lambda x: x["role"] == role, all_role_data))
            role_data.append(role)

    ### Exclude roles from --skip
    if skip is not None:
        for role in skip.split(","):
            role = role.strip()
            role_data = list(filter(lambda x: x["role"] != role, role_data))

    ### Map roles array to tags string for ansible
    if len(role_data) > 0:
        final_tags = []
        for role in role_data:
            role = role["tags"]
            if isinstance(role, list):
                role = role[0]
            role = role.strip()
            final_tags.append(role)

        arguments.append("--tags")
        arguments.append(",".join(final_tags))

    arguments.append(playbook)

    # If the program chrashes here, you should check the bitwarden because something's changed
    bw_response = bitwarden.get_bitwarden_item(
        "Discord (slack) webhooks for sadserver deploy"
    )["fields"]

    # makes the list of dicts one big dict
    discord_webhooks = {
        k: v
        for d in map(lambda it: {it["name"]: it["value"]}, bw_response)
        for k, v in d.items()
    }

    if host == "production":
        discord_deployment_webhook = discord_webhooks[
            "DISCORD_WEBHOOK_PRODUCTION_DEPLOYMENTS"
        ]
    else:
        discord_deployment_webhook = discord_webhooks[
            "DISCORD_WEBHOOK_STAGING_DEPLOYMENTS"
        ]

    if not check:
        notify_deploy_start(
            playbook,
            host,
            user,
            branch,
            revision,
            specified_roles,
            discord_deployment_webhook,
        )

    print("Running the following playbook:")
    print(" ".join(arguments))

    try:
        subprocess.run(arguments, check=True, env=env)
        if not check:
            notify_deploy_succes(
                playbook,
                host,
                user,
                branch,
                revision,
                specified_roles,
                discord_deployment_webhook,
            )

    except subprocess.CalledProcessError:
        if not check:
            notify_deploy_failure(
                playbook,
                host,
                user,
                branch,
                revision,
                specified_roles,
                discord_deployment_webhook,
            )


def current_branch_name() -> str:
    repo = Repo("..")
    return str(repo.active_branch)


def current_git_revision() -> str:
    repo = Repo("..")
    return str(repo.commit().hexsha)


def notify_deploy_start(
    playbook: str,
    host: str,
    user: str,
    git_branch: str,
    git_revision: str,
    roles: List[str],
    discord_webhook: str,
) -> None:
    roles_str = ", ".join(roles)
    if roles == []:
        roles_str = "All"
    discord_notify(
        f"**Deployment of playbook {playbook} to {host} started by {user}**\n"
        + f'Branch: {git_branch} - revision "{git_revision}"\n'
        + f"Roles: {roles_str}",
        ":construction:",
        "#46c4ff",
        discord_webhook,
    )


def notify_deploy_succes(
    playbook: str,
    host: str,
    user: str,
    git_branch: str,
    git_revision: str,
    roles: List[str],
    discord_webhook: str,
) -> None:
    roles_str = ", ".join(roles)
    if roles == []:
        roles_str = "All"
    discord_notify(
        f"**Deployment of playbook {playbook} to {host}, started by {user}, succesfully completed**\n"
        + f'Branch: {git_branch} - revision "{git_revision}"\n'
        + f"Roles: {roles_str}",
        ":construction:",
        "good",
        discord_webhook,
    )


def notify_deploy_failure(
    playbook: str,
    host: str,
    user: str,
    git_branch: str,
    git_revision: str,
    roles: List[str],
    discord_webhook: str,
) -> None:
    roles_str = ", ".join(roles)
    if roles == []:
        roles_str = "All"
    discord_notify(
        f"**Deployment of playbook {playbook} to {host}, started by {user}, FAILED!**\n"
        + f'Branch: {git_branch} - revision "{git_revision}"\n'
        + f"Roles: {roles_str}",
        ":exclamation:",
        "danger",
        discord_webhook,
    )


def discord_notify(message: str, icon: str, color: str, webhook_url: str) -> None:
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
        webhook_url,
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


if __name__ == "__main__":
    deploy()

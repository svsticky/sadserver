#!/usr/bin/env nix-shell
#!nix-shell -i python3 ../shell.nix

import enum
import json
import os
import pathlib
import subprocess
from typing import Any, Dict, List

import click


XDG_RUNTIME_DIR = pathlib.Path(os.getenv("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}"))
SESSION_KEY_CACHE_DIR = XDG_RUNTIME_DIR / "sadserver-bitwarden"
SESSION_KEY_CACHE_FILE = SESSION_KEY_CACHE_DIR / "cached-session-key"


class BitwardenStatus(enum.Enum):
    Unauthenticated = "unauthenticated"
    Locked = "locked"
    Unlocked = "unlocked"


@click.command()
@click.option(
    "--vault-id",
    type=click.Choice(["staging", "production"]),
    required=True,
    envvar="ANSIBLE_VAULT_IDENTITY",
)
@click.pass_context
def cli(ctx: click.Context, vault_id: str) -> None:
    """
    This script uses Bitwarden's CLI tool to print the Ansible Vault decryption
    key for the requested Vault ID to stdout.

    The Ansible Vault ID to print the password for may be specified by either
    passing the `--vault-id` parameter or by setting the ANSIBLE_VAULT_IDENTITY
    environment variable.

    This script manages the Bitwarden unlocking process for you: after
    executing this script at least once the Bitwarden session key is cached in
    a private directory and automatically reused for future invocations.

    This script is intended to be called automatically by Ansible.
    """

    bw_status = get_bitwarden_status()

    if bw_status == BitwardenStatus.Unauthenticated:
        ctx.fail("Error: Please log in to Bitwarden with `bw login` first.")

    # Unlock vault if it isn't already
    if bw_status == BitwardenStatus.Locked:
        click.echo("Unlocking Bitwarden.", err=True)
        session_key = get_bitwarden_session_key()
        os.environ["BW_SESSION"] = session_key

        # Edge case: if the user kept their system running for so long that the session
        # key is no longer valid we need to throw it away and rerun `bw unlock`.
        # This can happen if we're running on a laptop.
        if get_bitwarden_status() != BitwardenStatus.Unlocked:
            click.echo(
                "Failed to unlock using cached key, clearing cached session key.",
                err=True,
            )
            SESSION_KEY_CACHE_FILE.unlink()
            del os.environ["BW_SESSION"]

            session_key = get_bitwarden_session_key()
            os.environ["BW_SESSION"] = session_key

            # This should never happen, if fetching a new session key fails
            # get_bitwarden_session_key should throw an exception.
            assert (
                get_bitwarden_status() == BitwardenStatus.Unlocked
            ), "Unable to unlock vault even after clearing cached session key."

    bw_data = run_bitwarden_json_command(
        ["get", "item", "caa7fb69-913a-4f08-9d0f-a87f013d39d2"]
    )

    lookup = {x["name"]: x["value"] for x in bw_data["fields"]}
    print(lookup[vault_id])


def get_bitwarden_status() -> BitwardenStatus:
    bw_data = run_bitwarden_json_command(["status"])

    return BitwardenStatus(bw_data["status"])


def get_bitwarden_session_key() -> str:
    SESSION_KEY_CACHE_DIR.mkdir(mode=0o700, parents=False, exist_ok=True)

    if SESSION_KEY_CACHE_FILE.is_file():
        click.echo("Reusing session key from cache.", err=True)
        return SESSION_KEY_CACHE_FILE.read_text()
    else:
        click.echo("Unlocking Vault to get a new session key.", err=True)

        # Need the `--raw` here or `bw` will return data to source in a shell
        # instead of just the session key.
        session_key = run_bitwarden_command(["unlock", "--raw"])

        # Cache the key for next time
        SESSION_KEY_CACHE_FILE.touch(mode=0o600, exist_ok=True)
        SESSION_KEY_CACHE_FILE.write_text(session_key)
        return session_key


def run_bitwarden_command(args: List[str]) -> str:
    """
    Call `bw` with the provided arguments and return whatever it gives on
    standard out. Complain if the command exits with a non-zero status code.
    """
    cmd = ["bw"] + args

    try:
        result = subprocess.run(
            cmd,
            # Record the command's output instead of letting it go to stdout,
            # ensure that it's interpreted as text instead of bytes.
            # Note: we do not want to capture stderr, because this is used to
            # print prompts to the user (e.g. the password prompt).
            stdout=subprocess.PIPE,
            text=True,
            # Throw a CalledProcessError if exit code is non-zero.
            check=True,
        )
        return result.stdout

    except subprocess.CalledProcessError as e:
        ctx = click.get_current_context()
        ctx.fail(f"Error: \"{' '.join(cmd)}\" exited with code {e.returncode}")


def run_bitwarden_json_command(args: List[str]) -> Dict[str, Any]:
    """
    Call `bw` with the provided arguments and return its output parsed as JSON.
    """

    # Workaround: `bw` sometimes prints non-JSON status messages before
    # providing the output we want, e.g. "The session key is invalid.".
    # We can rely on the fact that the JSON will all be on one line and that it
    # will be the last line, so we just ignore this data if it happens.
    bw_output = run_bitwarden_command(args)
    lines = bw_output.split("\n")

    try:
        data = json.loads(lines[-1])

    except ValueError:
        ctx = click.get_current_context()
        ctx.fail(f"Failed to parse Bitwarden output of {args} as JSON!")

    assert isinstance(data, dict), "Expected Bitwarden output to be a dict!"
    assert all(
        [isinstance(key, str) for key in data.keys()]
    ), "Expected Bitwarden output's keys to be strings!"

    return data


if __name__ == "__main__":
    cli()

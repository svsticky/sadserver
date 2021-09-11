import click
import git
import os
import subprocess
import requests
import json


@click.command()
@click.option('--host', required=True, type=click.Choice(['staging', 'production']), help='The host to deploy to')
@click.option('--playbook', default='main.yml', help='Ansible playbook to run')
@click.option('--roles', default='', help='The roles to deploy')
@click.option('--check', is_flag=True, default=False, help='Perform a dry run')
def deploy(host, playbook, roles, check):
  if not check:
    verify_on_latest_master(host)

  # in the original script we doublecheck if production deploy is intended. Should we do that here?

  user = os.environ['USER']
  branch = current_branch_name()
  revision = current_git_revision()[:8]

  env = os.environ.copy()
  env['ANSIBLE_STDOUT_CALLBACK'] = 'yaml'
  env['ANSIBLE_VAULT_IDENTITY'] = host
  env['ANSIBLE_SSH_PIPELINING'] = 'true'
  env['ANSIBLE_VAULT_PASSWORD_FILE'] = './scripts/bitwarden-vault-pass.py'

  arguments = [
    'ansible-playbook',
    '--inventory',
    './hosts',
    '--diff',
    "--limit",
    host,
    '--extra-vars',
    f"playbook_revision={revision}",
  ]

  # Special scenario: When restore-backup.yml is run on staging, it needs to
  # access the production Vault secrets, so this adds the call for that to
  # the environment passed to ansible-playbook
  if playbook == 'playbooks/restore-backup.yml':
    arguments.append('--vault-id production@prompt')

  if check:
    arguments.append('--check')

  if roles != '':
    arguments.append('--tags')
    arguments.append(roles)

  arguments.append(playbook)

  if not check:
    notify_deploy_start(playbook, host, user, branch, revision)

  print("Running the following playbook:")
  print(' '.join(arguments))

  try:
    subprocess.run(
      arguments,
      check=True,
      env=env
    )
    if not check:
      notify_deploy_succes(playbook, host, branch, revision)

  except CalledProcessError:
    if not check:
      notify_deploy_fail(playbook, host, branch, revision)


def current_branch_name():
  repo = git.Repo('..')
  return repo.active_branch


def current_git_revision():
  repo = git.Repo('..')
  return repo.commit().hexsha


def notify_deploy_start(playbook, host, user, git_branch, git_revision):
  discord_notify(
    f"*Deployment of playbook {playbook} in {host} environment started by {user}*\n" +
    f"_(branch: {git_branch} - revision \"{git_revision}\")_",
    ':construction:',
    '#46c4ff'
  )

def notify_deploy_succes(playbook, host, git_branch, git_revision):
  discord_notify(
    f"*Deployment of playbook {playbook} in {host} environment succesfully completed*\n" +
    f"_(branch: {git_branch} - revision \"{git_revision}\")_",
    ':construction:',
    'good'
  )

def notify_deploy_failure(playbook, host, git_branch, git_revision):
  discord_notify(
    f"*Deployment of playbook {playbook} in {host} environment FAILED!*\n" +
    f"_(branch: {git_branch} - revision \"{git_revision}\")_",
    ':exclamation:',
    'danger'
  )

def discord_notify(message, icon, color):
  url = get_slack_webhook().strip()

  data = {
    'username': 'Ansible',
    'attachments': [
      {
        'color': color,
        'mrkdwn_in': [
          'text',
          'fields',
        ],
        'text': message,
      },
    ],
    'icon_emoji': icon,
  }

  r = requests.post(
    url,
    json=data,
  )

  if r.status_code != 200:
    raise click.ClickException(f"Discord failed with statuscode {r.status_code} and message {r.text}")

def verify_on_latest_master(host):
  repo = git.Repo('..')

  # not sure why str() needs to be called
  if host == 'production' and str(repo.active_branch) != 'master':
    raise click.ClickException('Please do not deploy anything but master to production')

  remote = repo.remotes.origin
  local_commit = repo.commit()
  remote_commit = remote.fetch()[0].commit

  if local_commit.hexsha != remote_commit.hexsha:
    raise click.ClickException('The remote is not on the same commit as your commit')

  # Diff against the working tree
  for x in repo.head.commit.diff(None):
    click.ClickException('There is uncommited in your working tree or staging area')


def get_slack_webhook():
  webhook_filename = '.slack-webhook'

  if not os.path.exists(webhook_filename):
    raise click.ClickException('Please create .slack-webhook with a webhook URL for deploy notifications')
  else:
    # maybe should be a try-catch block here
    with open(webhook_filename) as f:
      return f.read()


if __name__ == '__main__':
  deploy()

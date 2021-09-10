import click
import git
import os
import subprocess


@click.command()
@click.option('--host', required=True, type=click.Choice(['staging', 'production']), help='The host to deploy to')
@click.option('--playbook', default='main.yml', help='Ansible playbook to run')
@click.option('--check', is_flag=True, default=False, help='Perform a dry run')
def deploy(host, playbook, check):
  verify_on_latest_master(host)

  # in the original script we doublecheck if production deploy is intended. Should we do that here?

  # TODO: send discord messages with discordtee or equivalent

  # TODO: add the special casing for restore-backup.yml

  env = os.environ
  env['SLACKTEE_WEBHOOK'] = get_slack_webhook()
  env['ANSIBLE_STDOUT_CALLBACK'] = 'yaml'
  env['ANSIBLE_VAULT_IDENTITY'] = host
  env['ANSIBLE_SSH_PIPELINING'] = 'true'
  env['ANSIBLE_VAULT_PASSWORD_FILE'] = './scripts/bitwarden-vault-pass.py'

  subprocess.run([
    'ansible-playbook',
    '--inventory',
    './hosts',
    '--diff',
    "--limit",
    host,
    '--check',
    playbook,
    # TODO: add playbook revision
    ],
    env=env)


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
    pass#raise click.ClickException('There is uncommited in your working tree or staging area')


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

#!/usr/bin/env python3
'''
Generate the resulting .ssh/authorized_keys for a given user present in
vars.yml. If given multiple keys, will concatenate and deduplicate all keys.

Requires libyaml, pip install pyyaml.
'''
import argparse
import logging
import os.path
import yaml


VARSFILE = 'vars.yml'
KEYDIR = 'credentials/ssh'

def load_vars() -> dict:
    ''' Open and parse vars.yml. '''
    with open(VARSFILE, 'r') as varsfile:
        document = yaml.load(varsfile)

    return document

def parse_keylist(keys: [str]) -> [str]:
    ''' Parse the given list of keypaths and return the actual keys. '''
    result = []

    for keypath in keys:
        with open(os.path.join(KEYDIR, keypath)) as keylist:
            result.extend(
                [k.strip() for k in keylist.readlines()]
            )

    return result

def main():
    ''' Main entry point. '''
    parser = argparse.ArgumentParser()

    parser.add_argument(
        'user',
        nargs='+',
        help='user to get keys from'
    )

    args = parser.parse_args()

    vars = load_vars()

    result = set()

    for username in args.user:
        user = [u for u in vars['users'] if u['name'] == username]
        if not user:
            logging.error('No such user: %s', username)
            continue

        keypaths = [key['id'] for key in user[0]['keys']]
        keys = parse_keylist(keypaths)
        result.update(keys)

    print(
        '# Authorized_keys for user(s) {}'.format(
            ', '.join(args.user)
        )
    )

    for key in result:
        print(key)

if __name__ == '__main__':
    main()

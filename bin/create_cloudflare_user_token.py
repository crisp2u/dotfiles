"""Usage: CLOUDFLARE_EMAIL=myuser@sectorlabs.ro CLOUDFLARE_API_KEY=<global CF API key> python3 create_cloudflare_user_token.py --zones stage.olx-pk.run dev.olx-pk.run --name "Terraform PK dev"

This will create/update a Cloudflare API token to be used with Terraform. If the token with the
name already exists, it will be updated with the permissions and zones according to this script."""

import os
import sys
import json
import argparse
import requests
import logging
import difflib

from typing import Dict, List
from urllib.parse import urljoin
from collections import defaultdict

LOGGER = logging.getLogger(__name__)


class ArgumentParser(argparse.ArgumentParser):
    def error(self, message):
        sys.stderr.write('error: %s\n\n' % message)
        self.print_help()
        sys.exit(2)


class CloudflareAPI:
    url = 'https://api.cloudflare.com/client/v4/'
    account_scope = 'com.cloudflare.api.account'
    user_scope = 'com.cloudflare.api.user'
    zone_scope = 'com.cloudflare.api.account.zone'

    def __init__(self, email: str, api_key: str) -> None:
        self._session = requests.Session()
        self._session.headers.update({
            'X-Auth-Email': email,
            'X-Auth-Key': api_key,
        })

    def user(self) -> dict:
        response = self._session.get(self._create_url('user'))
        response.raise_for_status()
        return response.json()['result']

    def user_tokens(self) -> dict:
        response = self._session.get(self._create_url('user/tokens?per_page=50'))
        response.raise_for_status()

        return {
            user_token['name']: user_token
            for user_token in response.json()['result']
        }

    def accounts(self):
        response = self._session.get(self._create_url('accounts?per_page=50'))
        response.raise_for_status()

        return {
            account['name']: account
            for account in response.json()['result']
        }

    def zones(self):
        response = self._session.get(self._create_url('zones?status=active'))
        response.raise_for_status()

        return {
            zone['name']: zone
            for zone in response.json()['result']
        }

    def permission_groups(self) -> Dict[str, Dict[str, dict]]:
        response = self._session.get(self._create_url('user/tokens/permission_groups'))
        response.raise_for_status()

        permission_grouped_by_scope = defaultdict(dict)

        for permission_group in response.json()['result']:
            for scope in permission_group['scopes']:
                permission_grouped_by_scope[scope][permission_group['name']] = {
                    'id': permission_group['id'],
                    'name': permission_group['name'],
                }

        return permission_grouped_by_scope

    def update_user_token(self, name: str, policies: List[dict]) -> None:
        existing_user_token = self.user_tokens()[name]

        response = self._session.put(
            self._create_url(f"user/tokens/{existing_user_token['id']}"),
            json={
                **existing_user_token,
                'policies': policies,
            },
        )
        response.raise_for_status()
        return response.json()['result']

    def create_user_token(self, name: str, policies: List[dict]) -> None:
        response = self._session.post(self._create_url(f"user/tokens"), json={
            'name': name,
            'policies': policies,
        })
        response.raise_for_status()
        return response.json()['result']

    def _create_url(self, path: str) -> str:
        return urljoin(self.url, path)


def _summarize_policies(policies):
    print('')

    for policy in policies:
        for resource_key, resource_value in policy['resources'].items():
            print(' ', policy['effect'], resource_key, resource_value)

        for permission_group in policy['permission_groups']:
            print(' ', ' ', permission_group['id'], permission_group['name'])

        print('')



def main() -> int:
    logging.basicConfig(level='INFO')

    parser = ArgumentParser(description='Creates/updates a Cloudflare API to be used with Terraform for a specific zone. Environment variables CLOUDFLARE_EMAIL and CLOUDFLARE_API_KEY must be set.')
    parser.add_argument(
        '--include-accounts',
        type=str,
        nargs='+',
        help='Accounts the API token can access.',
    )
    parser.add_argument(
        '--exclude-accounts',
        type=str,
        nargs='+',
        help='Accounts the API token cannot access.',
    )
    parser.add_argument(
        '--include-account-zones',
        type=str,
        nargs='+',
        help='Accounts for which the API token can access zones',
    )
    parser.add_argument(
        '--include-zones',
        type=str,
        nargs='+',
        help='Zones the API token can access.',
    )
    parser.add_argument(
        '--exclude-zones',
        type=str,
        nargs='+',
        help='Zones the API token cannot access.',
    )
    parser.add_argument(
        '--name',
        type=str,
        required=True,
        help='Name to give to the API key (or to target for an update).'
    )
    options = parser.parse_args()

    cf_email = os.environ.get('CLOUDFLARE_EMAIL')
    cf_key = os.environ.get('CLOUDFLARE_API_KEY')
    cf_include_account_names = options.include_accounts or []
    cf_exclude_account_names = options.exclude_accounts or []
    cf_include_account_zone_names = options.include_account_zones or []
    cf_include_zone_names = options.include_zones or []
    cf_exclude_zone_names = options.exclude_zones or []
    cf_user_token_name = options.name

    if not cf_email or not cf_key:
        parser.error('environment variable CLOUDFLARE_EMAIL or CLOUDFLARE_API_KEY not set\n\n')
        return 2

    cf_api = CloudflareAPI(cf_email, cf_key)
    cf_user = cf_api.user()
    cf_accounts = cf_api.accounts()
    cf_zones = cf_api.zones()
    cf_user_tokens = cf_api.user_tokens()

    LOGGER.info(f"Authenticated as '{cf_user['email']}' with ID '{cf_user['id']}'")

    cf_accounts = {
        cf_account_name: cf_accounts.get(cf_account_name)
        for cf_account_name in cf_include_account_names + cf_exclude_account_names + cf_include_account_zone_names
    }
    for account_name, account in cf_accounts.items():
        if not account:
            LOGGER.error(f"Could not find a zone named '{account_name}'")
            return 1

        LOGGER.info(f"Identified account '{account_name}' as having ID '{account['id']}'")

    cf_zones = {
        cf_zone_name: cf_zones.get(cf_zone_name)
        for cf_zone_name in cf_include_zone_names + cf_exclude_zone_names
    }
    for zone_name, zone in cf_zones.items():
        if not zone:
            LOGGER.error(f"Could not find a zone named '{zone_name}'")
            return 1

        LOGGER.info(f"Identified zone '{zone_name}' as having ID '{zone['id']}'")

    cf_permission_groups = cf_api.permission_groups()

    cf_zone_permission_groups = [
        cf_permission_groups[cf_api.zone_scope]['Zone Settings Write'],
        cf_permission_groups[cf_api.zone_scope]['Zone Write'],
        cf_permission_groups[cf_api.zone_scope]['Workers Routes Write'],
        cf_permission_groups[cf_api.zone_scope]['SSL and Certificates Write'],
        cf_permission_groups[cf_api.zone_scope]['Logs Write'],
        cf_permission_groups[cf_api.zone_scope]['Page Rules Write'],
        cf_permission_groups[cf_api.zone_scope]['Firewall Services Write'],
        cf_permission_groups[cf_api.zone_scope]['DNS Write'],
    ]

    cf_user_permission_groups = [
        cf_permission_groups[cf_api.user_scope]['API Tokens Write'],
        cf_permission_groups[cf_api.user_scope]['User Details Write'],
    ]

    cf_account_permission_groups = [
        cf_permission_groups[cf_api.account_scope]['Account Rulesets Write'],
        cf_permission_groups[cf_api.account_scope]['Account Rule Lists Write'],
        cf_permission_groups[cf_api.account_scope]['Workers KV Storage Write'],
        cf_permission_groups[cf_api.account_scope]['Workers Scripts Write'],
        cf_permission_groups[cf_api.account_scope]['Account Firewall Access Rules Write'],
        cf_permission_groups[cf_api.account_scope]['Access: Apps and Policies Write'],
    ]

    cf_user_token_policies = [
        {
            'effect': 'allow',
            'permission_groups': cf_user_permission_groups,
            'resources': {
                f"{cf_api.user_scope}.{cf_user['id']}": '*',
            },
        },
    ]

    if cf_include_account_names:
        cf_user_token_policies.append({
            'effect': 'allow',
            'permission_groups': cf_account_permission_groups,
            'resources': {
                f"{cf_api.account_scope}.{cf_accounts[cf_account_name]['id']}": '*'
                for cf_account_name in cf_include_account_names
            },
        })
    else:
        cf_user_token_policies.append({
            'effect': 'allow',
            'permission_groups': cf_account_permission_groups,
            'resources': {
                f"{cf_api.account_scope}.*": '*',
            },
        })

    if cf_exclude_account_names:
        cf_user_token_policies.append({
            'effect': 'deny',
            'permission_groups': cf_account_permission_groups,
            'resources': {
                f"{cf_api.account_scope}.{cf_accounts[cf_account_name]['id']}": '*'
                for cf_account_name in cf_exclude_account_names
            },
        })

    if cf_include_zone_names:
        cf_user_token_policies.append({
            'effect': 'allow',
            'permission_groups': cf_zone_permission_groups,
            'resources': {
                f"{cf_api.zone_scope}.{cf_zones[cf_zone_name]['id']}": '*'
                for cf_zone_name in cf_include_zone_names
            },
        })
    else:
        cf_user_token_policies.append({
            'effect': 'allow',
            'permission_groups': cf_zone_permission_groups,
            'resources': {
                f"{cf_api.account_scope}.{cf_accounts[cf_account_name]['id']}": {
                    f'{cf_api.zone_scope}.*': '*'
                }
                for cf_account_name in cf_include_account_zone_names
            } if cf_include_account_zone_names else {f'{cf_api.zone_scope}.*': '*'}
        })

    if cf_exclude_zone_names:
        cf_user_token_policies.append({
            'effect': 'deny',
            'permission_groups': cf_zone_permission_groups,
            'resources': {
                f"{cf_api.zone_scope}.{cf_zones[cf_zone_name]['id']}": '*'
                for cf_zone_name in cf_exclude_zone_names
            },
        })

    cf_user_token = cf_user_tokens.get(cf_user_token_name)
    if not cf_user_token:
        LOGGER.info(f"No user token with name '{cf_user_token_name}' exists yet, creating new one")
        cf_user_token = cf_api.create_user_token(cf_user_token_name, cf_user_token_policies)
        LOGGER.info(f"User token '{cf_user_token_name}' created with ID '{cf_user_token['id']}'")
        LOGGER.info(f"New token value (secret): '{cf_user_token['value']}'")
    else:
        LOGGER.info(f"User token '{cf_user_token_name}' already exists with ID '{cf_user_token['id']}', updating it")
        cf_user_token = cf_api.update_user_token(cf_user_token_name, cf_user_token_policies)
        LOGGER.info(f"User token '{cf_user_token_name}' with ID '{cf_user_token['id']}' updated")

    return 0


if __name__ == '__main__':
    sys.exit(main())
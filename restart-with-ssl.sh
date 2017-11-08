#!/usr/bin/env bash

VAULT_ADDR_HTTP='http://127.0.0.1:8200'
VAULT_ADDR_HTTPS='https://127.0.0.1:8200'
SSL_KEY_PATH=/etc/montagu/vault_ssl_key

# Needs to be root because we write to /etc/montagu
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root via sudo"
    exit 1
fi

echo "MONTAGU VAULT BOOTSTRAP PROCESS"

if [ -f $SSL_KEY_PATH ]; then
    echo "ssl key already found at $SSL_KEY_PATH"
    echo
    echo "Remove it and rerun this script"
    exit 1
fi

if [ -z $VAULT_AUTH_GITHUB_TOKEN ]; then
    echo -n "Paste your github token: "
    read -s VAULT_AUTH_GITHUB_TOKEN
fi

VAULT_ADDR=$VAULT_ADDR_HTTPS vault status > /dev/null 2>&1
VAULT_STATUS=$?

# Before changing anything, test if we're running with https or not -
# this command should only be used when we have a vault running http:
if [ $VAULT_STATUS -eq 0 ]; then
    echo "Vault appears to be running OK"
    exit 1
elif [ $VAULT_STATUS -eq 2 ]; then
    echo "Vault is running with https but needs unsealing"
    exit 1
fi

# Then make sure that the vault is unsealed - we need to pull things
# out so it needs to be.
docker exec -it -e VAULT_ADDR=$VAULT_ADDR_HTTP montagu-vault vault status > /dev/null 2>&1
VAULT_STATUS=$?

if [ $VAULT_STATUS -eq 2 ]; then
    echo "Vault is sealed - can't continue"
    # exit 1
fi

## From here, fail on error:
set -e

echo "Retrieving ssl key"
docker exec -it -e VAULT_ADDR=$VAULT_ADDR_HTTP -e VAULT_AUTH_GITHUB_TOKEN=$VAULT_AUTH_GITHUB_TOKEN montagu-vault vault auth -method=github
docker exec -it -e VAULT_ADDR=$VAULT_ADDR_HTTP montagu-vault vault read -field=key secret/ssl/support > $SSL_KEY_PATH

# Secure the token
chmod 600 $SSL_KEY_PATH
sudo chown root:root $SSL_KEY_PATH

echo "Stopping http vault container"
docker stop montagu-vault

echo "Starting vault with https"
sudo ./run.sh $SSL_KEY_PATH

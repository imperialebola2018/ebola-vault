#!/usr/bin/env bash

VAULT_ADDR_HTTP='http://127.0.0.1:8200'
VAULT_ADDR_HTTPS='https://127.0.0.1:8200'
SSL_KEY_PATH=/etc/montagu/vault_ssl_key

echo "MONTAGU VAULT: unseal via loopback"

VAULT_ADDR=$VAULT_ADDR_HTTPS vault status > /dev/null 2>&1
VAULT_STATUS=$?

# Before changing anything, test if we're running with https or not -
# this command should only be used when we have a vault running http:
if [ $VAULT_STATUS -eq 0 ]; then
    echo "Vault appears to be running OK"
    # exit 1
elif [ $VAULT_STATUS -eq 2 ]; then
    echo "Vault is running with https but needs unsealing"
    # exit 1
fi

# Then make sure that the vault is unsealed - we need to pull things
# out so it needs to be.
docker exec -it -e VAULT_ADDR=$VAULT_ADDR_HTTP montagu-vault vault status > /dev/null 2>&1
VAULT_STATUS=$?

if [ $VAULT_STATUS -eq 0 ]; then
    echo "Vault not sealed - no need to unseal"
    # exit 1
fi

docker exec -e VAULT_ADDR=$VAULT_ADDR_HTTP -it montagu-vault vault unseal

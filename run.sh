#!/usr/bin/env bash
set -e

if [[ $# -eq 0 ]] ; then
	echo "Please provide path to SSL private key, or use ./run-no-ssl.sh"
	exit 0
fi


./include/start-vault.sh

private_key_path=$1
docker cp $private_key_path montagu-vault:/vault/config/ssl_private_key
docker exec montagu-vault touch /vault/config/go_signal

cat include/start-text.txt

echo ""
echo "Begin your ssh session with:"
echo "export VAULT_ADDR='https://support.montagu.dide.ic.ac.uk:8200'"
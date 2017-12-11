#!/usr/bin/env bash
set -e

HERE=$(dirname $0)

$HERE/include/start-vault.sh
docker exec -it montagu-vault ./decrypt-ssl-key.sh

cat $HERE/include/start-text.txt

echo ""
echo "Begin your ssh session with:"
echo "export VAULT_ADDR='https://support.montagu.dide.ic.ac.uk:8200'"

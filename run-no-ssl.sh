#!/usr/bin/env bash
set -e

echo "Starting Vault without SSL. Unless you are connecting via the local "
echo "loopback device, you have no guarantee you are not connecting to an "
echo "attacker."

./include/start-vault.sh
docker cp vault-insecure.conf montagu-vault:/vault/config/vault.conf
docker exec montagu-vault touch /vault/config/go_signal

cat include/start-text.txt

echo ""
echo "In addition, because SSL is disabled, you will need to begin your sh"
echo "session with: export VAULT_ADDR='http://127.0.0.1:8200'"

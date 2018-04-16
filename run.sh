#!/usr/bin/env bash
set -e

HERE=$(dirname $0)

MONTAGU_VAULT=montagu-vault
MONTAGU_VAULT_DATA=montagu_vault_data
MONTAGU_VAULT_LOGS=montagu_vault_logs

if ! docker volume inspect "$MONTAGU_VAULT_DATA" > /dev/null 2>&1; then
    echo "Error: docker volume $MONTAGU_VAULT_DATA does not exist"
    exit 1
fi

if ! docker volume inspect "$MONTAGU_VAULT_LOGS" > /dev/null 2>&1; then
    docker volume create "$MONTAGU_VAULT_LOGS"
fi

docker build -t $MONTAGU_VAULT $HERE

docker run -d --rm \
       --cap-add=IPC_LOCK \
       --name montagu-vault \
       -v $MONTAGU_VAULT_DATA:/vault/file \
       -v $MONTAGU_VAULT_LOGS:/vault/logs \
       -p "8200:8200" \
       $MONTAGU_VAULT

docker exec -it montagu-vault ./decrypt-ssl-key.sh

cat $HERE/include/start-text.txt

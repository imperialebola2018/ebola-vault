#!/usr/bin/env bash
set -e

HERE=$(dirname $0)

EBOLA_VAULT=ebola-vault
EBOLA_VAULT_DATA=ebola_vault_data
EBOLA_VAULT_LOGS=ebola_vault_logs

if ! docker volume inspect "$EBOLA_VAULT_DATA" > /dev/null 2>&1; then
    echo "Error: docker volume $EBOLA_VAULT_DATA does not exist"
    exit 1
fi

if ! docker volume inspect "$EBOLA_VAULT_LOGS" > /dev/null 2>&1; then
    docker volume create "$EBOLA_VAULT_LOGS"
fi

docker build -t $EBOLA_VAULT $HERE

docker run -d --rm \
       --cap-add=IPC_LOCK \
       --name ebola-vault \
       -v $EBOLA_VAULT_DATA:/vault/file \
       -v $EBOLA_VAULT_LOGS:/vault/logs \
       -p "8200:8200" \
       $EBOLA_VAULT

docker exec -it ebola-vault ./decrypt-ssl-key.sh

cat $HERE/include/start-text.txt

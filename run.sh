#!/usr/bin/env bash
set -e

HERE=$(dirname $0)

MONTAGU_VAULT=montagu-vault
docker build -t $MONTAGU_VAULT $HERE

docker run -d --rm \
       --cap-add=IPC_LOCK \
       --name montagu-vault \
       -v /montagu/vault/storage:/vault/file \
       -p "8200:8200" \
       $MONTAGU_VAULT

docker exec -it montagu-vault ./decrypt-ssl-key.sh

cat $HERE/include/start-text.txt

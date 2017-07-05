#!/usr/bin/env bash
set -e

mkdir -p workspace
docker run --rm \
    -v $PWD/workspace:/workspace \
    docker.montagu.dide.ic.ac.uk:5000/montagu-cert-tool:master \
    gen-self-signed /workspace

docker run -d \
    --cap-add=IPC_LOCK \
    --name montagu-vault \
    montagu-vault

docker cp workspace/certificate.pem montagu-vault:/vault/config/
docker cp workspace/ssl_key.pem montagu-vault:/vault/config/
rm -r -f workspace

echo "Vault is now running in montagu-vault container."
echo "Use docker exec -it montagu-vault /bin/sh to execute commands on CLI"
echo "Use ./init.sh to initialise new vault."
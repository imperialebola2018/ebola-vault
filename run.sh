#!/usr/bin/env bash
set -e

mkdir -p workspace
docker run --rm \
    -v $PWD/workspace:/workspace \
    docker.montagu.dide.ic.ac.uk:5000/montagu-cert-tool:master \
    gen-self-signed /workspace 127.0.0.1

docker run -d --rm \
    --cap-add=IPC_LOCK \
    --name montagu-vault \
    -v /vault/storage:/vault/file \
    -p "8200:8200" \
    montagu-vault

docker cp workspace/certificate.pem montagu-vault:/vault/config/
docker cp workspace/ssl_key.pem montagu-vault:/vault/config/
rm -r -f workspace

echo "Vault is now running in montagu-vault container."
echo "To execute vault CLI commands use: docker exec -it montagu-vault /bin/sh"
echo "To initialise new vault run sh in container and then:"
echo "    ./init.sh"
echo "    vault unseal (multiple times until vault is unsealed)"
echo "    ./first-time-setup.sh [ROOT_TOKEN]"

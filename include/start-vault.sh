docker run -d --rm \
    --cap-add=IPC_LOCK \
    --name montagu-vault \
    -v /vault/storage:/vault/file \
    -p "8200:8200" \
    docker.montagu.dide.ic.ac.uk:5000/montagu-vault:master
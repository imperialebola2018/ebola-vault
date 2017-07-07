#image=docker.montagu.dide.ic.ac.uk:5000/montagu-vault:master
#docker pull $image

image=montagu-vault
docker build -t $image .

docker run -d --rm \
    --cap-add=IPC_LOCK \
    --name montagu-vault \
    -v /montagu/vault/storage:/vault/file \
    -p "8200:8200" \
    $image
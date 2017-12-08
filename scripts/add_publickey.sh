#!/usr/bin/env bash

# This script is run on everyone's individual computers.  After it has
# been run we can reencrypt the key with this public key added to it.

set -e
if [ "$#" -ne 1 ]; then
    echo "Usage:\n    $0 <name>"
    exit 1
fi

NAME=$1
DEST="pubkey/${NAME}.pub"
SRC=~/.ssh/id_rsa
echo "Converting ssh key $SRC into public key $DEST"

mkdir -p pubkey
openssl req -x509 -new -key $SRC -days 3650 -nodes \
        -subj "/C=US/ST=*/L=*/O=*/OU=*/CN=Carol/" -out $DEST

echo "Success!"
echo
echo "Please add $DEST to git and commit"

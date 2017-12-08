#!/usr/bin/env bash
set -e

# https://gist.github.com/kennwhite/9918739
# https://www.bjornjohansen.no/encrypt-file-using-ssh-key
PATH_SECRET=ssl-key
FILE_CLEAR=$PATH_SECRET/ssl_private_key
FILE_ENC=$PATH_SECRET/ssl_private_key.enc
PATH_PUBKEY=$PATH_SECRET/pubkey
PATH_KEY=$PATH_SECRET/key

if [ ! -f $FILE_CLEAR ]; then
    echo "Reading ssl key from existing vault"
    export VAULT_ADDR='https://support.montagu.dide.ic.ac.uk:8200'
    if [ -z $VAULT_AUTH_GITHUB_TOKEN ]; then
        echo -n "Paste your github token: "
        read -s VAULT_AUTH_GITHUB_TOKEN
    fi
    vault auth -method=github
    vault read -field=key secret/ssl/support > $FILE_CLEAR
    function cleanup {
        echo "Removing ssl key"
        rm -f $FILE_CLEAR
    }
    trap cleanup EXIT
fi

# Generate the symmetric key and encrypt our ssl private key with it
export SYMKEY=`openssl rand 32 -hex`
openssl aes-256-cbc -in $FILE_CLEAR -out $FILE_ENC -pass "env:SYMKEY"

## Then encrypt the symmetric key with each public key:
rm -rf $PATH_KEY
mkdir -p $PATH_KEY
for KEY_NAME in $(ls -1 $PATH_PUBKEY); do
    FILE_PUBKEY="$PATH_PUBKEY/$KEY_NAME"
    echo "Creating key for $KEY_NAME"
    echo $SYMKEY |
        openssl rsautl -encrypt -oaep -pubin \
                -inkey <(ssh-keygen -e -f $FILE_PUBKEY -m PKCS8) \
                -out "$PATH_KEY/$KEY_NAME"
done

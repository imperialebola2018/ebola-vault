#!/bin/sh
set -e
FILE_ENC=/vault/config/ssl_private_key.enc
FILE_CLEAR=/vault/config/ssl_private_key
echo "On your PC, run"
echo
echo "  git clone https://github.com/vimc/montagu-vault"
echo "  ./montagu-vault/ssl-key/decrypt-key.sh <your-key-name>"
echo
echo "where <your-key-name> corresponds to an entry in ssl-key/pubkey/"
echo "that you have the private key for.  If you can't remember, run the"
echo "decrypt-key command with no arguments and it will print value names."
echo
echo "Then copy the printed symmetric key: "
echo -n "key: "
read SYMKEY
export SYMKEY
openssl aes-256-cbc -d -in $FILE_ENC -out $FILE_CLEAR -pass env:SYMKEY
echo "Wrote out the ssl certificate to $FILE_CLEAR"
touch /vault/config/go_signal

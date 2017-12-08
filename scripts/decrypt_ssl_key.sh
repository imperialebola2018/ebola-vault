#!/bin/sh
set -e
FILE_ENC=/vault/config/ssl_private_key.enc
FILE_CLEAR=/vault/config/ssl_private_key
echo "On your PC, in montagu-vault, run"
echo
echo "  ./ssl-key/decrypt_key.sh <your-key-name>"
echo
echo "where <your-key-name> corresponds to an entry in keys/ that you"
echo "have the private key for"
echo
echo "Then copy the printed symmetric key: "
echo -n "key: "
read SYMKEY
export SYMKEY
openssl aes-256-cbc -d -in $FILE_ENC -out $FILE_CLEAR -pass env:SYMKEY
echo "Wrote out the ssl certificate to $FILE_CLEAR"
touch /vault/config/go_signal

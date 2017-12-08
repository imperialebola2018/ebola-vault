#!/usr/bin/env bash
set -e
NAME=$1
PATH_KEY="ssl-key/key"
FILE_KEY="$PATH_KEY/$NAME"
FILE_PRIVKEY=$HOME/.ssh/id_rsa

if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 <key-name>"
    echo
    echo "Valid key names:"
    for k in $(ls -1 "$PATH_KEY"); do
        echo "  - $k"
    done
    exit 1
fi

if [ ! -f $FILE_KEY ]; then
    echo "Key $FILE_KEY not found"
    exit 1
fi

if [ ! -f $FILE_PRIVKEY ]; then
    echo "ssh private key $FILE_PRIVKEY not found"
    exit 1
fi

SYMKEY=$(openssl rsautl -decrypt -oaep -inkey $FILE_PRIVKEY -in $FILE_KEY)
echo "Symmetric key is"
echo "  $SYMKEY"

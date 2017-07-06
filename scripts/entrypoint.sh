#!/bin/sh
set -e

root="/vault/config"
mkdir -p $root

a="$root/certificate.pem"
b="$root/ssl_key.pem"

echo "Waiting for SSL certificate files at:"
echo "- $a"
echo "- $b"

while [ ! -e $a ]
do
    sleep 2
done

while [ ! -e $b ]
do
    sleep 2
done

echo "Certificate files detected. Running vault"
vault server -config /vault/config/vault.conf

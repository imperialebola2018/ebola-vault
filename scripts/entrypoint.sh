#!/bin/sh
set -e

root="/vault/config"
mkdir -p $root

f="$root/go_signal"

echo "Waiting for signal file at $f"

while [ ! -e $f ]
do
    sleep 2
done

echo "Go signal detected. Running vault"
vault server -config /vault/config/vault.conf

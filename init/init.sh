#!/bin/sh

set -e

# To be run to initialise a brand new vault
export VAULT_ADDR=https://ebola2017.dide.ic.ac.uk:8200
vault operator init \
      -key-shares=4 \
      -key-threshold=2

cat <<EOF
Copy each of the keys above onto a USB key as individual files and
distribute one key and the root token to each of Rich, Wes, Anne and Tini

After that, at least two people need to unseal the vault.

Then run ./init/first-time-setup.sh
EOF

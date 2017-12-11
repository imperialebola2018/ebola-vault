#!/bin/sh

# To be run to initialise a brand new vault
vault init \
      -key-shares=4 \
      -key-threshold=2

cat <<EOF
Copy each of the keys above onto a USB key as individual files and
distribute one key and the root token to each of Martin, Wes, Alex and
Rich.

After that, at least two people need to unseal the vault.

Then run ./init/first-time-setup.sh
EOF

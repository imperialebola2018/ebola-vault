#!/bin/sh

# To be run to initialise a brand new vault
vault init \
	-tls-skip-verify \
	-key-shares=4 \
	-key-threshold=2

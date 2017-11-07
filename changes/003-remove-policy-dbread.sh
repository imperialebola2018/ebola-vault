#!/bin/sh
set -e

if [ -f config/dbread.policy ]; then
    echo "ERROR: First remove config/dbread.policy (see VIMC-587)"
    exit 1
fi

echo "Removing science read permissions from /secret/database"
vault delete auth/github/map/teams/science
vault policy-delete dbread

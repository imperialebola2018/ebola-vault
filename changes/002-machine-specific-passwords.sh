#!/bin/sh
set -e
echo "Enabling the science team to read from /secret/database/science"
vault policy-write dbread-science config/dbread-science.policy
vault write auth/github/map/teams/science value=dbread-science

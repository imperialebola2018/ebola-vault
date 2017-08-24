#/bin/sh
set -e
echo "Enabling the science team to read from /secret/database"
vault policy-write dbread config/dbread.policy
vault write auth/github/map/teams/science value=dbread

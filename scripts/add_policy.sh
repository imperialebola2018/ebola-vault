#/bin/sh
set -e

echo -n "Root token: "
read -s TOKEN

vault auth $TOKEN
vault write auth/github/map/teams/science value=dbread
vault policy-write dbread /vault/config/dbread.policy

echo "Enabled GitHub authentication for the science team in the vimc organization"
echo "You can now authenticate against the vault using"
echo "    vault auth -method=github token=[GITHUB PERSONAL ACCESS TOKEN]"
echo "To obtain your GitHub personal access token see https://help.github.com/articles/creating-an-access-token-for-command-line-use/"

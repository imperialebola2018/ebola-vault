# Ebola secrets vault

[Vault](https://www.vaultproject.io/) is a piece of software for storing secrets. They have an official [docker image](https://hub.docker.com/_/vault/).

The code here is a fork of the [vimc project `montagu-vault`](https://github.com/vimc/montagu-vault).  Much of the docs here are incorrect because they refer to the wrong machine.  The original docs exist at [`README.montagu.md`](README.montagu.md) and at the vimc repository.

## Using the vault

### Installing

Get the binary from here: https://www.vaultproject.io/downloads.html

### Create a personal access token

1. Go to https://github.com/settings/tokens
2. Click "**Generate new token**"
3. Enter a "**Token description**" (e.g., Ebola2018 vault access)
4. Select "**user** Update all user data"

### Authenticating against the vault

1. `export VAULT_ADDR='https://ebola2018.dide.ic.ac.uk:8200'`
2. `export VAULT_AUTH_GITHUB_TOKEN=<personal access token>`. To generate a 
   personal access token, go to GitHub > Settings > Personal Access Tokens. The
   new token must have the 'user' scope.
3. `vault auth -method=github`


### From R

Add to your "~/.Renviron" file the lines

```
VAULT_ADDR=https://ebola2018.dide.ic.ac.uk:8200
VAULT_AUTH_GITHUB_TOKEN=<your token>
VAULTR_AUTH_METHOD=github
```

```r
# install.packages("drat")
drat:::add("vimc")
install.packages("vaultr")
cl <- vaultr::vault_client()
```

### Reading secrets

```
vault read secret/some/path
```

### Setup

```
set -ex
docker volume create ebola_vault_data
docker volume create ebola_vault_logs
./run.sh
./init/init.sh
./save_keys
```

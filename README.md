# Ebola secrets vault

[Vault](https://www.vaultproject.io/) is a piece of software for storing secrets. They have an official [docker image](https://hub.docker.com/_/vault/).

The code here is a fork of the [vimc project `montagu-vault`](https://github.com/vimc/montagu-vault).  Much of the docs here are incorrect because they refer to the wrong machine.  The original docs exist at [`README.montagu.md`](README.montagu.md) and at the vimc repository.

## Using the vault

### Authenticating against the vault

1. `export VAULT_ADDR='https://ebola2017.dide.ic.ac.uk:8200'`
2. `export VAULT_AUTH_GITHUB_TOKEN=<personal access token>`. To generate a 
   personal access token, go to GitHub > Settings > Personal Access Tokens. The
   new token must have the 'user' scope.
3. `vault auth -method=github`

### Reading secrets

```
vault read secret/some/path
```

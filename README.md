# Montagu secrets vault 
[Vault](https://www.vaultproject.io/) is a piece of softeware for storing 
secrets. They have an official [docker image](https://hub.docker.com/_/vault/).

## Using the vault
### Authenticating against the vault
1. `export VAULT_ADDR='https://support.montagu.dide.ic.ac.uk:8200'`
2. `export VAULT_AUTH_GITHUB_TOKEN=<personal access token>`. To generate a 
   personal access token, go to GitHub > Settings > Personal Access Tokens. The
   new token must have the 'user' scope.
3. `vault auth -method=github`

### Reading secrets
```
vault read secret/some/path
```

### Restarting the vault

If the Vault docker container is stopped (for example, because the support 
machine is rebooted), follow these steps:

1. Begin a session on the support machine.
2. Clone this respository: `git clone https://github.com/vimc/montagu-vault.git`
3. `cd montagu-vault`
4. `./run.sh`
5. Follow the instructions it prints *on your local machine* to retrieve the key required to unlock the ssl key.
6. End your remote session.
7. Collaborate with keyholders to unseal the vault, as described in the next
   section.

The process for restoring the vault from backup is identical.  If you have been following the [Disaster Recovery guide](https://github.com/vimc/montagu/tree/master/docs/DisasterRecovery.md) then the vault volume will be ready to use.

### Unsealing the vault

The vault is stored on disk at `/vault/storage` on the support machine. However,
it is encrypted on disk. Any time the Vault restarts (or is restored from 
backup) we have to provide enough unseal keys to allow it to decrypt the 
contents in memory.

Each keyholder up to the required number must run on their machine:

1. `export VAULT_ADDR=https://support.montagu.dide.ic.ac.uk:8200`
2. `vault unseal` (you will be prompted for your unseal key)

This shouldn't happen often.

## Setting up the vault

### Repository contents

This repository contains:

* Files for extending the base docker image with our own configuration:
    - `Dockerfile`
    - `vault.conf`
    - `standard.policy`. This grants users of the development team in GitHub
      permissions.
    - `teamcity.sh`, which builds and pushes the image, and is run on TeamCity
    - `scripts/entrypoint.sh`. This makes the container wait until we've copied
      across necessary files (like the SSL private key) before starting Vault.
* Files for spinning up a new container with the correct options:
    - `run.sh`
    - `include/start-vault.sh`
    - `include/start-text.txt`
* Scripts to be run to set up a brand new Vault (we shouldn't need these again)
  unless we suffer a catastrophic backup failure and have to generate new 
  secrets):
    - `scripts/init.sh`
    - `scripts/first-time-setup.sh`

### How to create a brand new Vault

Since we hopefully won't do this again, this is more documentation of what 
Martin did to get us here:

1. Begin a session on the support machine.
1. `./run.sh SSL_PRIVATE_KEY_PATH` 
1. `docker exec -it montagu-vault /bin/sh`
1. `export VAULT_ADDR=https://support.montagu.dide.ic.ac.uk:8200`. This is
   because the SSL certificate is signed for that URL, not for 127.0.0.1,
   which Vault defaults to.
1. `./init.sh`: This generates four new unseal keys, and one root token.
   Copy these these onto a USB key as individual files.
1. The unseal keys and root token are then distributed to each of the four
   keyholders (Martin, Wes, Alex, Rich), so that each gets one unseal key
    and everyone has the root access token.
1. Everyone unseals the vault (see below).
1. `./first-time-setup.sh` (Still inside the vault container).


### Interaction with the registry

In my first take on this I followed the pattern of other Montagu components:
build a Docker image in TeamCity, push it to the registry, and then `run.sh`
just pulled the image down and ran it.

However, thinking it through I realized that we want to store the registry
SSL key in the Vault. So then we'd have a chicken and egg situation, where
we can't spin up the registry without the vault, and we can't run the vault
without pulling it from the registry.

The simple solution was just to move building the docker image into the
run script - it's a oneliner, and you need the full repository and Docker
to run anyway. TeamCity still builds an image, as that's a useful way of
checking that this works, and in some test cases it may be convenient to
pull down a built image from the registry.

### Applying changes

Changes to the vault are stored in [`changes`](changes).  These will typically interact with things outside of `/secret` and need elevated vault privledges.  We need to do this properly at some point with issuing temporary root tokens, but for now:

```
vault auth
```

pasting in the root token as needed.  When you are done, do

```
vault auth -method=github
```

to revert to normal permissions.

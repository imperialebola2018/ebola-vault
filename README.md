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
4. `sudo ./run.sh /etc/montagu/vault_ssl_key` (You need root to read the SSL
   key, not actually to run the vault)
5. End your remote session.
6. Collaborate with keyholders to unseal the vault, as described in the next
   section.

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
    - `vault.conf` (and `vault-no-ssl.conf`)
    - `standard.policy`. This grants users of the development team in GitHub
      permissions.
    - `teamcity.sh`, which builds and pushes the image, and is run on TeamCity
    - `scripts/entrypoint.sh`. This makes the container wait until we've copied
      across necessary files (like the SSL private key) before starting Vault.
* Files for spinning up a new container with the correct options:
    - `run.sh` (and `run-no-ssl.sh`)
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

### Restoring the Vault from backup
Let's imagine that the support machine has died and we need to set up a new one.
This is a bit ticklish because we can't secure access to the vault without the 
private SSL key, but we store this in the vault. It's okay though: We can 
bootstrap by accessing the vault locally, from inside the Docker container, get
the key out, and then restart with SSL.

If the support machine hasn't died

1. Follow the restore instructions in the 
   [Disaster Recovery guide](https://github.com/vimc/montagu/docs/DisasterRecovery.md)
2. `./run-no-ssl.sh`
3. Each keyholder must unseal the Vault over a localhost connect, like so:
    1. `ssh support.montagu.dide.ic.ac.uk`
    2. `./unseal-loopback.sh` (you will be prompted for your unseal key) - at least two people must do this step
4. With the vault up, but only secure over the loopback devices, restart the vault with ssl enabled using the ssl key is itself stored in the vault
    1. `ssh support.montagu.dide.ic.ac.uk`
    2. `./restart-with-ssl.sh`
5. Finally, go through the normal, remote unseal process, as described in
   "Unsealing the vault".

Alternative approaches to consider:

1. Don't backup the SSL key, just generate a new one and get a new certificate
   if the support machines dies. Imperial seem to be able to create them pretty
   fast.
2. Backup the SSL key directly with our backup provider.

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

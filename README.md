# Montagu secrets vault 

[Vault](https://www.vaultproject.io/) is a piece of software for storing secrets. They have an official [docker image](https://hub.docker.com/_/vault/).

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

### Restarting and/or restoring the vault

If the Vault docker container is stopped (for example, because the support 
machine is rebooted, or because you are restoring from backup), follow these steps:

1. Begin a session on the support machine.
2. Clone this respository: `git clone https://github.com/vimc/montagu-vault.git`
3. `cd montagu-vault`
4. `./run.sh`
5. Follow the instructions it prints *on your local machine* to retrieve the key required to unlock the ssl key.
6. End your remote session.
7. Collaborate with keyholders to unseal the vault, as described in the next
   section.

The process for restoring the vault from backup is identical.  If you have been following the [Disaster Recovery guide](https://github.com/vimc/montagu/tree/master/docs/DisasterRecovery.md) then the vault volume will be ready to use.

The tricky bit in this process is getting the ssl certificate private key into the vault container.  This is documented in more detail [here](ssl-key/README.md) but if you follow the instructions above things should work.  See the [ssl-key instructions](ssl-key/README.md) if you need to add a new ssh-key or replace the ssl certificate.

#### Testing the restore locally

You will need a copy of the vault's (encrypted) storage which can be retrieved by running, within a fresh checkout of this repository:

```
ssh -t support.montagu sudo tar -zcvf ~/storage.tar.gz /montagu/vault/storage
scp support.montagu:storage.tar.gz .
sudo tar -zxvf storage.tar.gz -C /
ssh support.montagu rm ~/storage.tar.gz
rm storage.tar.gz
```

Then, in order to simulate access to the vault over https, add the following line to `/etc/hosts`:

```
127.0.0.1 support.montagu.dide.ic.ac.uk support
```

Verify with `ping support.montagu.dide.ic.ac.uk` which should then print `64 bytes from localhost (127.0.0.1): ...`

At this point you can now run `./run.sh` to test the restore process

**Do not forget to remove the line from `/etc/hosts` when you're done**.  Otherwise all sorts of things will fail (registry, future vault access, etc).

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
    - `ssl-key/ssl_private_key.enc`. An encrypted copy of our ssl private key
    - `scripts/decrypt-ssl-key.sh`.  Script to help decrypt the ssl private key
    - `ssl-key`. Futher files to support encrypting and decrypting keys for the ssl private key (see the [README.md](ssl-key/README.md) in that directory for further information)
* Files for spinning up a new container with the correct options:
    - `run.sh`
    - `include/start-text.txt`
* Scripts to be run to set up a brand new Vault (we shouldn't need these again)
  unless we suffer a catastrophic backup failure and have to generate new 
  secrets):
    - `scripts/init.sh`
    - `scripts/first-time-setup.sh`

### How we initially created the vault

Since we hopefully won't do this again, this is more documentation of what 
Martin did to get us here (adapted to use the new ssl key handling)

1. Begin a session on the support machine.
1. Ensure that `/montagu/vault/storage` is empty or does not exist
1. `./run.sh`

The following commands can then be run from any computer on the VPN

1. export VAULT_ADDR=https://support.montagu.dide.ic.ac.uk:8200
1. Run `vault init -key-shares=4 -key-threshold=2`: This generates four new unseal keys, and one root token. Copy these these onto a USB key as individual files.
1. The unseal keys and root token are then distributed to each of the four
   keyholders (Martin, Wes, Alex, Rich), so that each gets one unseal key
    and everyone has the root access token.
1. Everyone unseals the vault using `vault unseal` (see above).
1. `./init/first-time-setup.sh`

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

# Details of the recovery process

The recovery process, with less magic and more explanation, is this:

### Start the vault with http

```sh
./run-no-ssl.sh
```

This starts the vault (via `./include/start-vault.sh`) which

* builds a vault image
* starts the vault image but does not actually start the vault
* copies a configuration that disables ssl into the container
* sends a "go signal" to the vault, which then servers insecurely over http

### Unseal the vault

Unseal the vault by having 2 people log on to the machine and run `./unseal-loopback.sh` which

* checks that the vault is really running without ssl and is sealed
* runs `vault unseal` over the loopback device in the vault container, which is the equivalent of `docker exec -it montagu-vault sh; VAULT_ADDR=http://127.0.0.1:8200 vault unseal`

### Restart the vault with https

Log onto the machine and run

```
./restart-with-ssl.sh
```

which

* checks that the vault is really running without ssl and is unsealed
* extracts the ssl from the vault (`vault read -field=key secret/ssl/support` over the loopback interface in the vault container) and saves this as `/etc/montagu/vault_ssl_key` with permissions `600`, owned by root
* stops the vault container
* starts the vault container with ssl

### Unseal the vault

Can be done as usual from people's individual computers

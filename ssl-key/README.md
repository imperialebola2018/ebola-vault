# ssl certificate encryption

Getting the ssl certificate private key encrypted so that we don't need to use the vault to bootstrap the vault.

The idea is we:

1. encrypt the private key using a symmetric key
2. encrypt a copy of that symmetric key using our ssh public keys
3. the encrypted certificate and the encrypted symmetric keys are added to the montagu repository

Then do decrypt:

1. locally decrypt the symmetric key using a ssh private key
2. pass the symmetric key to the vault startup script interactively

A multi-key approach like [this](https://gist.github.com/kennwhite/9918739) seems nice but I _really_ don't want to encourage us to be copying around our private keys!  So with this scheme we locally (i.e., on our host machines) decrypt the symmetric key and then we provide that interactively during vault startup.

## To add a new key

* Copy the ssh **public** key - `~/.ssh/id_rsa.pub` - into `pubkey/` with a descriptive name, and commit to git
* Run the script `./ssl-key/encrypt.sh` which will create a new set of encrypted keys

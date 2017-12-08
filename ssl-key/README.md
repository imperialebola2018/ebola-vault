# ssl certificate encryption

Getting the ssl certificate private key encrypted so that we don't need to use the vault to bootstrap the vault.

The idea is we:

1. encrypt the private key using a symmetric key
2. encrypt a copy of that symmetric key using our ssh public keys
3. the encrypted certificate and the encrypted symmetric keys are added to the montagu repository

Then do decrypt:

1. locally decrypt the symmetric key using a ssh private key
2. pass the symmetric key to the vault startup script interactively

The commands used come from [this post](https://www.bjornjohansen.no/encrypt-file-using-ssh-key).

A multi-key approach like [this](https://gist.github.com/kennwhite/9918739) seems nice but I _really_ don't want to encourage us to be copying around our private keys!  So with this scheme we locally (i.e., on our host machines) decrypt the symmetric key and then we provide that interactively during vault startup.

## To add a new public key

(e.g., if you rebuild your computer and add a new key, a new person joins the project, etc).

* Copy the ssh **public** key - `~/.ssh/id_rsa.pub` - into `pubkey/` with a descriptive name, and commit to git
* Run the script `./ssl-key/encrypt.sh` which will create a new set of encrypted keys
* Run `git add ssl-key/pub ssl-key/key` to add the public key and encrypted symmetric key, commit and push.  There is no need to redeploy the vault.

## To replace the ssl certificate private key

* Copy the public parts of the certificate into `certs/`
* Copy the new certificate private key to `~/ssl-key/ssl_private_key`
* Run the script `./ssl-key/encrypt.sh`
* Remove `ssl-key/ssl_private_key`
* Run `git add ssl-key/key ssl-key/ssl_private_key.enc`, then commit and push
* Redeploy vault

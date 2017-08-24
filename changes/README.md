Ordered set of changes made to the running docker container

The idea here being that we can record the changes that were made.  If we ever rebuild the container we can copy these over into the script that does the first-time setup

All of these require the root token (or, based on [VIMC-584](https://vimc.myjetbrains.com/youtrack/issue/VIMC-584) a new root token based on getting quorum).

One might set the root token this way:

```
echo -n "Root token: "
read -s TOKEN
vault auth $TOKEN
```

Which can be done via `./auth-root.sh`.  Be aware that this sets the root token in `~/.vault-token` which is probably not what is desired.  So after running this, run something like

```
vault auth -method=github
```

to reset the token to be a non-root token

File access remains a bit tricky - when running in the docker container eventually, we will need to write things so that the workdir is set to the right point.  For now, write any file access relative to the root of this repo (e.g., `config/dbread.policy`) and if we do merge these into the initial setup, then it should just be a case of adding `-w /vault` to the run command

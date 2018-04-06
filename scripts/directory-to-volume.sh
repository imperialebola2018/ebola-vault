#!/usr/bin/env bash
# copy the contents of a directory into a new docker volume

set -e

if [ "$#" -ne 2 ]; then
    echo "Usage $0 <source> <destination>"
    exit 1
fi

SRC="$1"
DEST="$2"

if [ ! -d $SRC ]; then
    echo "Error: path $SRC must be a directory"
    exit 1
fi

if docker volume inspect "$DEST" > /dev/null 2>&1; then
    echo "Error: docker volume $DEST already exists"
    exit 1
fi

SRC=$(realpath $SRC)

echo -n "Creating docker volume "
docker volume create "$DEST"

echo "Copying files"
docker run \
       --rm \
       -v "$SRC":/src \
       -v "$DEST":/dest \
       alpine:latest \
       ash -c "cd /src; tar cf - . | (cd /dest && tar xf -)"

echo "Done"

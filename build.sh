#!/bin/bash

set -ueo pipefail

USER=$(grep -P 'ENV\s+USER=".+?"' Dockerfile | cut -d'"' -f2)
NAME=$(grep -P 'ENV\s+NAME=".+?"' Dockerfile | cut -d'"' -f2)
VERSION=$(grep -P 'ENV\s+VERSION=".+?"' Dockerfile | cut -d'"' -f2)
TAG="$USER/$NAME:$VERSION"

NAME=${NAME//-builder}

DIR=${0%/*}
cd "$DIR"

echo "Building: $NAME $VERSION"
echo
docker build -t "$TAG" .
docker tag "$TAG" "$USER/$NAME:latest"

echo "Copy $NAME $VERSION debian package to $(pwd)/"
docker run --rm -v "$(pwd)":/mnt/ "$TAG"
echo

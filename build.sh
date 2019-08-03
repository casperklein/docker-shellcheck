#!/bin/bash

VERSION="$(</etc/debian_version)"

echo "Building shellcheck for Debian $VERSION"
echo
docker build -t shellcheck --build-arg version="$VERSION" .
echo

echo "Copy binary to $(pwd)/shellcheck"
docker run -it -v "$(pwd)":/mnt/ shellcheck
echo

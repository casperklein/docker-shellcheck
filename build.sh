#!/bin/bash

VERSION="$(</etc/debian_version)"

echo "Building shellcheck for Debian $VERSION"
echo
docker build -t shellcheck-builder --build-arg version="${VERSION:-10}" .
echo

echo "Copy binary to $(pwd)/shellcheck"
docker run --rm -v "$(pwd)":/mnt/ shellcheck-builder
echo

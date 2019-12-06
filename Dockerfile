ARG	version=10
FROM	debian:$version-slim as build

ENV	USER="casperklein"
ENV	NAME="shellcheck-builder"
ENV	VERSION="0.7.0"

ENV	GIT_REPO="https://github.com/koalaman/shellcheck"
ENV	GIT_COMMIT="b7b4d5d29e401858074b0d36d7bb53da58c3932d"

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Install packages
RUN	apt-get update \
&&	apt-get -y --no-install-recommends install git cabal-install ca-certificates \
&&	cabal update

# Get and build shellcheck
WORKDIR	/$NAME
RUN	git init                        # make a new blank repository
RUN	git remote add origin $GIT_REPO # add a remote
RUN	git fetch origin $GIT_COMMIT    # fetch commit of interest
RUN	git reset --hard FETCH_HEAD     # reset this repository's master branch to the commit of interest
RUN	cabal install

# Copy root filesystem
COPY	rootfs /

# Prepare debian package build
WORKDIR	/deb
RUN	mv /root/.cabal/bin/shellcheck .

# Create debian package with checkinstall
RUN	apt-get install -y --no-install-recommends file dpkg-dev && dpkg -i /checkinstall_1.6.2-4_amd64.deb
RUN	checkinstall -y --install=no \
			--pkgname=shellcheck \
			--pkgversion=$VERSION \
			--maintainer=$USER@$NAME:$VERSION \
			--pkggroup=devel

# Move debian package to /mnt on container start
CMD	mv shellcheck_${VERSION}*.deb /mnt

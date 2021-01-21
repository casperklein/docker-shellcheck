FROM	debian:10-slim as build

ENV	GIT_USER="koalaman"
ENV	GIT_REPO="shellcheck"
ENV	GIT_COMMIT="f7547c9a5ad0cec60f7b765881051bf4a56d8a80"
ENV	GIT_ARCHIVE="https://github.com/$GIT_USER/$GIT_REPO/archive/$GIT_COMMIT.tar.gz"

ENV	PACKAGES="file checkinstall dpkg-dev cabal-install ca-certificates"

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Install packages
ENV	DEBIAN_FRONTEND=noninteractive
RUN	echo 'deb http://deb.debian.org/debian buster-backports main' > /etc/apt/sources.list.d/buster-backports.list \
&&	apt-get update \
&&	apt-get -y upgrade \
&&	apt-get -y --no-install-recommends install $PACKAGES

# Download source
WORKDIR	/$GIT_REPO
ADD	$GIT_ARCHIVE /
RUN	tar --strip-component 1 -xzvf /$GIT_COMMIT.tar.gz && rm /$GIT_COMMIT.tar.gz

# Copy root filesystem
COPY	rootfs /

# Build shellcheck
RUN	cabal update \
&&	cabal install \
&&	mv /root/.cabal/bin/shellcheck .

# Create debian package with checkinstall
RUN	echo 'ShellCheck, a static analysis tool for shell scripts.' > description-pak
ENV	APP="shellcheck"
ENV	MAINTAINER="casperklein@docker-shellcheck-builder"
ENV	GROUP="admin"
ARG	VERSION
RUN	checkinstall -y --install=no			\
			--pkgname=$APP			\
			--pkgversion=$VERSION		\
			--maintainer=$MAINTAINER	\
			--pkggroup=$GROUP

# Move debian package to /mnt on container start
CMD	mv ${APP}_*.deb /mnt

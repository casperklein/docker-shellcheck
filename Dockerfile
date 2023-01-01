FROM	debian:11-slim as build

ARG	GIT_USER="koalaman"
ARG	GIT_REPO="shellcheck"
ARG	GIT_COMMIT="v0.9.0"
ARG	GIT_ARCHIVE="https://github.com/$GIT_USER/$GIT_REPO/archive/$GIT_COMMIT.tar.gz"

ARG	PACKAGES="file checkinstall dpkg-dev cabal-install ca-certificates"

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Install packages
ARG	DEBIAN_FRONTEND=noninteractive
RUN	apt-get update \
&&	apt-get -y upgrade \
&&	apt-get -y --no-install-recommends install $PACKAGES \
&&	rm -rf /var/lib/apt/lists/*

# Download source
WORKDIR	/$GIT_REPO
ADD	$GIT_ARCHIVE /
RUN	tar --strip-component 1 -xzvf /$GIT_COMMIT.tar.gz && rm /$GIT_COMMIT.tar.gz

# Copy root filesystem
COPY	rootfs /

# Build shellcheck
RUN	cabal update \
&&	cabal install --installdir /sc \
&&	mv /sc/shellcheck .

# Create debian package with checkinstall
ARG	APP="shellcheck"
ARG	GROUP="admin"
ARG	MAINTAINER="casperklein@docker-shellcheck-builder"
ARG	VERSION="unknown"

RUN	echo 'ShellCheck, a static analysis tool for shell scripts.' > description-pak \
&&	checkinstall -y --install=no			\
			--pkgname=$APP			\
			--pkgversion=$VERSION		\
			--maintainer=$MAINTAINER	\
			--pkggroup=$GROUP

# Move debian package to /mnt on container start
CMD	["bash", "-c", "mv ${APP}_*.deb /mnt"]

LABEL	org.opencontainers.image.description="Build shellcheck and create debian package"
LABEL	org.opencontainers.image.source="https://github.com/casperklein/docker-shellcheck-builder/"
LABEL	org.opencontainers.image.title="docker-shellcheck-builder"
LABEL	org.opencontainers.image.version="$VERSION"

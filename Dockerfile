FROM	debian:11-slim as build

ENV	GIT_USER="koalaman"
ENV	GIT_REPO="shellcheck"
ENV	GIT_COMMIT="v0.8.0"
ENV	GIT_ARCHIVE="https://github.com/$GIT_USER/$GIT_REPO/archive/$GIT_COMMIT.tar.gz"

ENV	PACKAGES="file checkinstall dpkg-dev cabal-install ca-certificates"

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Install packages
ENV	DEBIAN_FRONTEND=noninteractive
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
ENV	APP="shellcheck"
ENV	MAINTAINER="casperklein@docker-shellcheck-builder"
ENV	GROUP="admin"
ARG	VERSION
RUN	echo 'ShellCheck, a static analysis tool for shell scripts.' > description-pak \
&&	checkinstall -y --install=no			\
			--pkgname=$APP			\
			--pkgversion=$VERSION		\
			--maintainer=$MAINTAINER	\
			--pkggroup=$GROUP

# Move debian package to /mnt on container start
CMD	["bash", "-c", "mv ${APP}_*.deb /mnt"]

ARG	version=10
FROM	debian:$version-slim as build

ENV	USER="casperklein"
ENV	NAME="shellcheck-builder"
ENV	VERSION="0.7.1"
ENV	APP="shellcheck"
ENV	GROUP="devel"

ENV	PACKAGES="cabal-install ca-certificates"

ENV	GIT_USER="koalaman"
ENV	GIT_REPO="shellcheck"
ENV	GIT_COMMIT="f7547c9a5ad0cec60f7b765881051bf4a56d8a80"
ENV	GIT_ARCHIVE="https://github.com/$GIT_USER/$GIT_REPO/archive/$GIT_COMMIT.tar.gz"

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Install packages
RUN	apt-get update \
&&	apt-get -y --no-install-recommends install $PACKAGES
RUN	cabal update

# Get and build shellcheck
WORKDIR	/$NAME
ADD	$GIT_ARCHIVE /
RUN	tar --strip-component 1 -xzvf /$GIT_COMMIT.tar.gz && rm /$GIT_COMMIT.tar.gz
RUN	cabal install

# Copy root filesystem
COPY	rootfs /

# Prepare debian package build
# see also rootfs/shellcheck/Makefile
WORKDIR	/shellcheck
RUN	mv /root/.cabal/bin/shellcheck .
RUN	echo 'ShellCheck, a static analysis tool for shell scripts.' > description-pak

# Create debian package with checkinstall
RUN	MACHINE=$(uname -m);    \
	case "$MACHINE" in      \
	x86_64)                 \
		ARCH="amd64"    \
		;;              \
	aarch64)                \
		ARCH="arm64"    \
		;;              \
	*)                      \
		ARCH="armhf"    \
		;;              \
	esac;                   \
	apt-get -y --no-install-recommends install file dpkg-dev && dpkg -i /checkinstall_1.6.2-4_$ARCH.deb
RUN	checkinstall -y --install=no \
			--pkgname=$APP \
			--pkgversion=$VERSION \
			--maintainer=$USER@$NAME \
			--pkggroup=$GROUP

# Move debian package to /mnt on container start
CMD	mv ${APP}_${VERSION}-1_*.deb /mnt

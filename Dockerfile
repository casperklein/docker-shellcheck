ARG	version=10
FROM	debian:$version-slim as build

ENV	USER="casperklein"
ENV	NAME="shellcheck-builder"
ENV	VERSION="0.7.0"
ENV	APP="shellcheck"
ENV	GROUP="devel"

ENV	PACKAGES="cabal-install ca-certificates"

ENV	GIT_COMMIT="b7b4d5d29e401858074b0d36d7bb53da58c3932d"
ENV	GIT_ARCHIVE="https://github.com/koalaman/shellcheck/archive/$GIT_COMMIT.tar.gz"

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Install packages
RUN	apt-get update \
&&	apt-get -y --no-install-recommends install $PACKAGES
RUN	cabal update

# Get and build shellcheck
WORKDIR	/$NAME
ADD	$GIT_ARCHIVE /$NAME
RUN	tar xzvf $GIT_COMMIT.tar.gz
WORKDIR	/$NAME/$APP-$GIT_COMMIT
RUN	cabal install

# Copy root filesystem
COPY	rootfs /

# Prepare debian package build
# see also rootfs/shellcheck/Makefile
WORKDIR	/shellcheck
RUN	mv /root/.cabal/bin/shellcheck .
RUN	echo 'ShellCheck, a static analysis tool for shell scripts.' > description-pak

# Create debian package with checkinstall
RUN     MASCHINE=$(uname -m);   \
	case "$MASCHINE" in     \
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

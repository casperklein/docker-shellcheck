ARG	version=10
FROM	debian:$version-slim

# Install packages
RUN 	apt-get update \
&&	apt-get -y install git cabal-install \
&&	cabal update

# Get and build shellcheck
RUN	git clone https://github.com/koalaman/shellcheck
WORKDIR /shellcheck
RUN	cabal install

# Move shellcheck binary to /mnt on container start
CMD	cp ~/.cabal/bin/shellcheck /mnt

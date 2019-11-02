ARG	version=10
FROM	debian:$version-slim

# Install packages
RUN 	apt-get update \
&&	apt-get -y --no-install-recommends install git cabal-install ca-certificates \
&&	cabal update

# Get and build shellcheck
RUN	git clone https://github.com/koalaman/shellcheck
WORKDIR /shellcheck
RUN	cabal install

# Move shellcheck binary to /mnt on container start
CMD	["/bin/cp", "/root/.cabal/bin/shellcheck", "/mnt"]

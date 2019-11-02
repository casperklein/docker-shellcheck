ARG	version=10
FROM	debian:$version-slim as build

# Install packages
RUN 	apt-get update \
&&	apt-get -y --no-install-recommends install git cabal-install ca-certificates \
&&	cabal update

# Get and build shellcheck
RUN	git clone https://github.com/koalaman/shellcheck
WORKDIR /shellcheck
RUN	cabal install

# Build final image
#FROM	debian:$version-slim
#COPY	--from=build /root/.cabal/bin/shellcheck /root/.cabal/bin/shellcheck

# Move shellcheck binary to /mnt on container start
CMD	["/bin/cp", "/root/.cabal/bin/shellcheck", "/mnt"]

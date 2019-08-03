ARG	version

FROM	debian:$version

RUN 	apt-get update && \
	apt-get -y install git cabal-install && \
	cabal update && \
	git clone https://github.com/koalaman/shellcheck

WORKDIR /shellcheck

RUN	cabal install

CMD	cp ~/.cabal/bin/shellcheck /mnt

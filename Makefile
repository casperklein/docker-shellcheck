# all targets are phony (no files to check)
.PHONY: default build clean install uninstall

USER := $(shell grep -P 'ENV\s+USER=".+?"' Dockerfile | cut -d'"' -f2)
NAME := $(shell grep -P 'ENV\s+NAME=".+?"' Dockerfile | cut -d'"' -f2)
VERSION := $(shell grep -P 'ENV\s+VERSION=".+?"' Dockerfile | cut -d'"' -f2)

default: build

build:
	./build-deb.sh

clean:
	rm -f shellcheck_$(VERSION)-1*.deb
	docker rmi $(USER)/$(NAME):$(VERSION); \
	docker rmi $(USER)/$(NAME):latest

install:
	dpkg -i shellcheck_$(VERSION)-1*.deb

uninstall:
	apt-get purge shellcheck

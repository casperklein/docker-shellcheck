# all targets are phony (no files to check)
.PHONY: default build clean push install uninstall

default: build

build:
	./build.sh

clean:
	rm -f shellcheck
	docker rmi casperklein/shellcheck-builder

push:
	docker push casperklein/shellcheck-builder

install:
	cp shellcheck /usr/local/bin/

uninstall:
	rm -f /usr/local/bin/shellcheck

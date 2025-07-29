REVISION := $(shell git rev-parse --short HEAD)
XDG_CACHE_HOME ?= ${HOME}/.cache

build:
	docker build --pull -t ghr-builder --target ghr-builder .
	docker build -t ghr-web --target ghr-web .
	docker build -t ghr -t ghr -t "ghr:$(REVISION)" --target ghr "--build-arg=REVISION=$(REVISION)" .

build-web:
	@docker compose build web

release:
	git push origin master
	git tag "$(REVISION)"
	git push origin "$(REVISION)"

push: build
	docker tag "ghr:$(REVISION)" "flori303/ghr:$(REVISION)"
	docker push "flori303/ghr:$(REVISION)"

build-info:
	@echo "flori303/ghr:$(REVISION)"

grype: build-web
	@docker run -e TERM -e COLORTERM --tty --pull always --rm --volume "${XDG_CACHE_HOME}/grype:/.cache/grype" --volume /var/run/docker.sock:/var/run/docker.sock --name Grype anchore/grype:latest --add-cpes-if-none --by-cve ghr

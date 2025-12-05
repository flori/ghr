REVISION := $(shell git rev-parse --short HEAD)
XDG_CACHE_HOME ?= ${HOME}/.cache
TAG ?= ${GITHUB_REF_NAME}

check-%:
	@if [ "${${*}}" = "" ]; then \
		echo >&2 "Environment variable $* not set"; \
		exit 1; \
	fi

build:
	docker build --pull -t ghr-builder --target ghr-builder .
	docker build -t ghr-web --target ghr-web .
	docker build -t ghr -t ghr -t "ghr:$(REVISION)" --target ghr "--build-arg=REVISION=$(REVISION)" .

build-web:
	@docker compose build web

validate-tag:
	@if ! echo "${TAG}" | grep -qE '^v[0-9]+\.[0-9]+\.[0-9]+$$'; then \
		echo >&2 "Error: TAG must be in the format 'v1.2.3'"; \
		exit 1; \
	fi # '

release: check-TAG validate-tag
	git tag "$(TAG)"
	git push origin "$(TAG)"
	git push origin master

push: check-TAG build
	docker tag "ghr:$(REVISION)" "flori303/ghr:$(TAG)"
	docker push "flori303/ghr:$(TAG)"

build-info: check-TAG validate-tag
	@echo "flori303/ghr:$(TAG)"

grype: build-web
	@docker run -e TERM -e COLORTERM --tty --pull always --rm --volume "${XDG_CACHE_HOME}/grype:/.cache/grype" --volume /var/run/docker.sock:/var/run/docker.sock --name Grype anchore/grype:latest --add-cpes-if-none --by-cve ghr

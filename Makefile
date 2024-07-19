REVISION := $(shell git rev-parse --short HEAD)

build:
	docker build --pull -t ghr-builder --target ghr-builder .
	docker build -t ghr-web --target ghr-web .
	docker build -t ghr -t ghr -t ghr:$(REVISION) --target ghr --build-arg=REVISION=$(REVISION) .

build-web:
	@docker compose build web

push: build
	docker tag ghr:$(REVISION) flori303/ghr:$(REVISION)
	docker push flori303/ghr:$(REVISION)

build-info:
	@echo flori303/ghr:$(REVISION)

grype: build-web
	@docker run --pull always --rm --volume /var/run/docker.sock:/var/run/docker.sock --name Grype anchore/grype:latest --add-cpes-if-none --by-cve ghr

.PHONY: build push test

DOCKER_IMAGE=overv/openstreetmap-tile-server
DOCKER_REPO?=

REMOTE_REPO=
ifneq (${DOCKER_REPO},)
	REMOTE_REPO="${DOCKER_REPO}/"
endif

build:
	docker build -t ${REMOTE_REPO}${DOCKER_IMAGE} .

push: build
	docker push ${REMOTE_REPO}${DOCKER_IMAGE}:latest

test: build
	docker volume create openstreetmap-data
	docker run --rm -v openstreetmap-data:/var/lib/postgresql/12/main ${REMOTE_REPO}${DOCKER_IMAGE} import
	docker run --rm -v openstreetmap-data:/var/lib/postgresql/12/main -p 8080:80 -d ${REMOTE_REPO}${DOCKER_IMAGE} run

stop:
	docker rm -f `docker ps | grep '${REMOTE_REPO}${DOCKER_IMAGE}' | awk '{ print $$1 }'` || true
	docker volume rm -f openstreetmap-data

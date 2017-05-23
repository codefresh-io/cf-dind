DOCKER_VERSION ?= 17.05

CF_PUSHER_VER ?= v2
CF_PULLER_VER ?= v2
CF_LOGGER_VER ?= 0.0.15
GIT_CLONE_VER ?= v7
CF_BUILDER_VER ?= v5


.PHONY: all dind pull copy build clean test

all: dind pull copy build

dind: 
	docker run -d --rm --privileged -p 23751:2375 --name cfpull docker:$(DOCKER_VERSION)-dind --storage-driver overlay2

pull: 
	docker --host=:23751 pull codefresh/cf-docker-pusher:$(CF_PUSHER_VER)
	docker --host=:23751 pull codefresh/cf-docker-puller:$(CF_PULLER_VER)
	docker --host=:23751 pull codefresh/cf-container-logger:$(CF_LOGGER_VER)
	docker --host=:23751 pull codefresh/git-clone-workflow:$(GIT_CLONE_VER)
	docker --host=:23751 pull codefresh/cf-docker-builder:$(CF_BUILDER_VER)
	echo "==== Pulled CF images ===="
	docker --host=:23751 images

copy:
	docker --host=:23751 save codefresh/cf-docker-pusher:$(CF_PUSHER_VER) > cf-docker-pusher_$(CF_PUSHER_VER).tar
	docker --host=:23751 save codefresh/cf-docker-puller:$(CF_PULLER_VER) > cf-docker-puller_$(CF_PULLER_VER).tar
	docker --host=:23751 save codefresh/cf-container-logger:$(CF_LOGGER_VER) > cf-container-logger_$(CF_LOGGER_VER).tar
	docker --host=:23751 save codefresh/git-clone-workflow:$(GIT_CLONE_VER) > git-clone-workflow_$(GIT_CLONE_VER).tar
	docker --host=:23751 save codefresh/cf-docker-builder:$(CF_BUILDER_VER) > cf-docker-builder_$(CF_BUILDER_VER).tar

build: 
	docker build -t codefresh/cfdind:$(DOCKER_VERSION) -f Dockerfile.$(DOCKER_VERSION) .

clean:
	docker rm -f cfpull

test:
	docker run -d --rm --privileged -p 23752:2375 --name cfdind codefresh/cfdind:$(DOCKER_VERSION) --storage-driver overlay2
	docker exec -it cfdind ./init.sh
	docker --host=:23752 images
	docker rm -f cfdind



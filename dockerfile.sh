#!/usr/bin/env bash

IMAGE_NAME=${1:-codefresh/cf-dind:master}
BUILD_DOCKER_ADDR="192.168.99.100"
BUILD_DOCKER_PORT=9998
BUILD_DOCKER_HOST=tcp://${BUILD_DOCKER_ADDR}:${BUILD_DOCKER_PORT}

docker run --name cf-dind-build-daemon -p ${BUILD_DOCKER_PORT}:${BUILD_DOCKER_PORT} -d --privileged docker:17.05.0-ce-dind dockerd -H tcp://0.0.0.0:${BUILD_DOCKER_PORT}

docker build --build-arg BUILD_DOCKER_HOST=${BUILD_DOCKER_HOST} -t ${IMAGE_NAME} .

FROM docker:17.05.0-ce-dind

ARG BUILD_DOCKER_HOST

COPY *.sh cf-images-* init-daemon.json /

RUN echo "  BUILD DOCKER_HOST=$BUILD_DOCKER_HOST " && DOCKER_HOST=$BUILD_DOCKER_HOST /build.sh

CMD ["/run.sh"]



FROM docker:18.09.0-dind

ARG BUILD_DOCKER_HOST

COPY *.sh cf-images-* init-daemon.json default-daemon.json /

RUN apk add bash --no-cache && \
    chmod a+x *.sh && \
    echo "  BUILD DOCKER_HOST=$BUILD_DOCKER_HOST " && \
    DOCKER_HOST=$BUILD_DOCKER_HOST /build.sh

CMD ["/run.sh"]

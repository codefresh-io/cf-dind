# Codefresh dind image contains general cf-images to save pull time during build
# Must set DOCKER_HOST and maybe other DOCKER_CERT + DOCKER_TLS_VERIFY using --build-arg
# Example:
#    docker build --build-arg DOCKER_HOST=tcp://docker:9998 -t codefresh/cf-dind:17.05.0-1 .
FROM docker:17.05.0-ce-dind

ARG BUILD_DOCKER_HOST

COPY *.sh cf-images-* init-daemon.json /

RUN echo "  BUILD DOCKER_HOST=$BUILD_DOCKER_HOST " && DOCKER_HOST=$BUILD_DOCKER_HOST /build.sh

# ENTRYPOINT ["run"]
CMD ["/run.sh"]



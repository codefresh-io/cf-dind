#!/bin/sh

echo "starting dockerd ..."
sh /usr/local/bin/dind dockerd -H unix:///var/run/docker.sock --storage-driver overlay --storage-opt "overlay.override_kernel_check=1" > /tmp/build-daemon.log 2>&1 &

echo "pulling images ..."
timeout -t 30 sh -c "while ! docker ps
do
  echo 'waiting for docker ....'
  cat /tmp/build-daemon.log
  sleep 2
done" && \
docker pull codefresh/cf-docker-pusher:v2 && \
docker pull codefresh/cf-docker-puller:v2 && \
docker pull codefresh/cf-container-logger:0.0.15 && \
docker pull codefresh/git-clone-workflow:v7 && \
docker pull codefresh/cf-docker-builder:v5

pkill dockerd

rm -rf var/run/docker.sock




#!/bin/sh
#
# Load CF Images and starts dind
# Firstly we start sock-only init daemon and load images from /cfimages/*init.tar
# Then we stop init daemon, start regular daemon with mounted /etc/docker/daemon.json
#   and load all remaining images in /cfimages/*run.tar in background

load_images() {
    local TARS=$1
    local DOCKER_OPTS=$2
    echo "$(date) - loadind images from ${TARS} to docker $DOCKER_OPTS "
    timeout -t 20 sh -c "while ! docker $DOCKER_OPTS ps
    do
      echo 'waiting for docker ....'
      sleep 1
    done" &&
        for ii in ${TARS}; do
          echo "    $(date) - docker $DOCKER_OPTS load < $ii "
          docker $DOCKER_OPTS load < $ii
        done
}

# Starting init daemon in backgroud
rm -fv /var/run/*docker.pid

echo "$(date) - Starting init daemon for docker load ..."
DOCKER_HOST_INIT=unix:///var/run/init-docker.sock
DOCKER_PIDFILE_INIT=/var/run/init-docker.pid
dockerd --config-file /init-daemon.json > /tmp/dockerd-init.log 2>&1 &


# Loading init images by init daemon
load_images /cfimages/*init.tar " -H ${DOCKER_HOST_INIT} " 2>&1 | tee /tmp/docker-load.log

# Killing init daemon
DOCKER_PID_INIT=$(cat ${DOCKER_PIDFILE_INIT})
echo "Killing init daemon - pid=$DOCKER_PID_INIT "
kill $DOCKER_PID_INIT

# Adding cleaner
if [[ -n "${DOCKER_CLEANER_CRON}" ]]; then
  echo "${DOCKER_CLEANER_CRON} $(realpath $DIR/docker-cleaner.sh) " | crontab
  crond
fi

# Starting load run images in background
load_images /cfimages/*run.tar >>/tmp/docker-load.log 2>&1 &

# Starting run daemon
rm -fv /var/run/docker.pid
mkdir -p /var/run/codefresh

echo "$(date) - Starting dockerd with /etc/docker/daemon.json: "
cat /etc/docker/daemon.json

dockerd


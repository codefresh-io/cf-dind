#!/bin/bash
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

kill_docker_by_pid(){
    local DOCKER_PID=$1
    echo -e "\n------- $(date) \nKilling dockerd DOCKER_PID = ${DOCKER_PID}"
    [[ -z "${DOCKER_PID}" ]] && echo "Error: DOCKER_PID 1 param is empty" && return 1

    kill ${DOCKER_PID}
    echo "Waiting for dockerd to exit ..."
    local CNT=0
    while ( pstree -p ${DOCKER_PID} | grep dockerd )
    do
       (( CNT++ ))
       echo ".... dockerd is still running - $(date)"
       if (( CNT >= 60 )); then
         echo "Killing dockerd"
         kill -9 ${DOCKER_PID}
         break
       fi
       sleep 1
    done
}

sigterm_trap(){
   echo "${1:-SIGTERM} received at $(date)"


   echo "killing DOCKER_PID ${DOCKER_PID}"
   kill_docker_by_pid $DOCKER_PID

   echo "Running processes: "
   ps -ef
   echo "Exiting at $(date) "
}
trap sigterm_trap SIGTERM SIGINT

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
kill_docker_by_pid $DOCKER_PID_INIT


# Starting load run images in background
load_images /cfimages/*run.tar >>/tmp/docker-load.log 2>&1 &


# Adding cleaner
if [[ -n "${DOCKER_CLEANER_CRON}" ]]; then
  echo "${DOCKER_CLEANER_CRON} $(realpath $(dirname $0)/docker-cleaner.sh) " | tee -a /etc/crontabs/root
  crond
fi

# Starting run daemon
rm -fv /var/run/docker.pid
mkdir -p /var/run/codefresh

# Setup Client certificate ca
if [[ -n "${CODEFRESH_CLIENT_CA_DATA}" ]]; then
  CODEFRESH_CLIENT_CA_FILE=${CODEFRESH_CLIENT_CA_FILE:-/etc/ssl/cf-client/ca.pem}
  mkdir -pv $(dirname ${CODEFRESH_CLIENT_CA_FILE} )
  echo ${CODEFRESH_CLIENT_CA_DATA} | base64 -d >> ${CODEFRESH_CLIENT_CA_FILE}
fi

# creating daemon json
if [[ ! -f /etc/docker/daemon.json ]]; then
  DAEMON_JSON=${DAEMON_JSON:-/default-daemon.json}
  mkdir -p /etc/docker
  cp -v ${DAEMON_JSON} /etc/docker/daemon.json
fi
echo "$(date) - Starting dockerd with /etc/docker/daemon.json: "
cat /etc/docker/daemon.json

dockerd ${DOCKERD_PARAMS} <&- &
CNT=0
while ! test -f /var/run/docker.pid || test -z "$(cat /var/run/docker.pid)" || ! docker ps
do
  echo "$(date) - Waiting for docker to start"
  sleep 2
done

DOCKER_PID=$(cat /var/run/docker.pid)
echo "DOCKER_PID = ${DOCKER_PID} "
wait ${DOCKER_PID}


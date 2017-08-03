#!/bin/sh
#
# Adding cleaner
if [[ -n "${DOCKER_CLEANER_CRON}" ]]; then
  echo "${DOCKER_CLEANER_CRON} $(realpath $(dirname $0)/docker-cleaner.sh) " | tee -a /etc/crontabs/root
  crond
fi

# Starting run daemon
rm -fv /var/run/docker.pid
mkdir -p /var/run/codefresh

echo "$(date) - Starting dockerd with /etc/docker/daemon.json: "
cat /etc/docker/daemon.json

dockerd

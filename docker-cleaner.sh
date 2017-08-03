#!/bin/sh
echo "$0 - $(date)" >> /var/log/cleaner.log
docker run --rm --name rt-cleaner -v /var/run/docker.sock:/var/run/docker.sock:rw --label io.codefresh.owner=codefresh -e GRACE_PERIOD_SECONDS=86400 --cpu-shares=10 codefresh/cf-runtime-cleaner:latest ./docker-gc >> /var/log/cleaner.log 2>&1
### Commands to test cf-dind image

##### Run on Docker Machine
docker run -it --rm -v $(pwd)/daemon.json:/etc/docker/daemon.json -v /mnt/sda1/codefresh/dind-1:/var/lib/docker:rw -v /mnt/sda1/var/lib/boot2docker/cfcerts:/etc/ssl/cf:ro codefresh/cf-dind:17.05.0-overlay-v1 sh
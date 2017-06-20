### Commands to test cf-dind image

##### Run on Docker Machine
```
# upload daemon.json and certificates to docker-machine before
docker run --name cf-dind-test-1 -it --rm  --privileged -v /mnt/sda1/codefresh/dind-daemon.json:/etc/docker/daemon.json \
     -v /mnt/sda1/codefresh/dind-1:/var/lib/docker:rw -v /mnt/sda1/var/lib/boot2docker/cfcerts:/etc/ssl/cf:ro \
      codefresh/cf-dind:17.05.0-overlay-v2

# from different session
docker exec -it cf-dind-test-1 docker images

```
Output:
REPOSITORY                      TAG                 IMAGE ID            CREATED             SIZE
codefresh/cf-git-cloner         v1                  a2c6f208d2ed        8 days ago          28.4MB
codefresh/cf-docker-pusher      v2                  75eb9df1fcac        7 weeks ago         37.8MB
codefresh/cf-container-logger   0.0.15              508bac3f4ab4        7 weeks ago         90.1MB
codefresh/cf-docker-puller      v2                  1be9663c94bb        7 weeks ago         38MB
codefresh/cf-docker-builder     v5                  980e8eed5c83        3 months ago        58.2MB

# cf-dind

## What is inside?

Docker-in-Docker (dind) image with Codefresh build helper images stored as `tar` in `/cfimages` directory.

## How to build?
```
./dockerfile.sh
```

TODO: build with codefresh.yml

### How to test?

see test/README.md

### Support different Docker versions

 Create `Dockerfile.VERSION` file for each version (same content; different `FROM`)


## How to run?

When creating new CF **dind** instance, it should be initialized with pre-loaded CF build helper images (stored as `tar` files). Execute `init.sh` script once.

```sh
$ # run cf-dind
$ docker run -d --rm -v /path-to/daemon.json:/etc/docker/daemon.json -v /tmp/dind-1:/var/lib/docker:rw -v /etc/ssl/cf:/etc/ssl/cf:ro codefresh/cf-dind:17.05.0-overlay-v1
$
```
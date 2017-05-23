# cf-dind

## What is inside?

Docker-in-Docker (dind) image with Codefresh build helper images stored as `tar` in `/cf-images` directory.

## How to build?

```
$ make
```

### How to test?

```
$ make test
```

### Support different Docker versions

1. Override ENV variable for `DOCKER_VERSION` (default: `17.05`).
2. Create `Dockerfile.VERSION` file for each version (same content; different `FROM`) 


## How to run?

When creating new CF **dind** instance, it should be initialized with pre-loaded CF build helper images (stored as `tar` files). Execute `init.sh` script once.

```sh
$ # run cfdind
$ docker run -d --rm --privileged -p 23752:2375 --name cfdind codefresh/cfdind:17.05 --storage-driver overlay2
$
$ # load all CF helper images from tar
$ docker exec -it cfdind ./init.sh
$
$ # see images loaded
$ docker --host=:23752 images
```

#!/bin/sh

save_images() {
    local IMAGES_LIST=$1
    local IMAGES_SAVE=""
    while read image; do
      docker pull ${image}
      IMAGES_SAVE="${IMAGES_SAVE} $image"
    done < $IMAGES_LIST
    echo docker save -o ${IMAGES_DIR}/${IMAGES_LIST}.tar ${IMAGES_SAVE}
    docker save -o ${IMAGES_DIR}/${IMAGES_LIST}.tar ${IMAGES_SAVE}
}

DIR=$(dirname $0)

echo "Staring $0 at $(date) "
echo "DOCKER_HOST=$DOCKER_HOST"

IMAGES_LIST_INIT=cf-images-init
IMAGES_LIST_RUN=cf-images-run

IMAGES_DIR=${DIR}/cfimages
mkdir -p $IMAGES_DIR

save_images ${IMAGES_LIST_INIT}

save_images ${IMAGES_LIST_RUN}


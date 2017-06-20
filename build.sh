#!/bin/sh

DIR=$(dirname $0)

echo "Staring $0 at $(date) "
echo "DOCKER_HOST=$DOCKER_HOST"

IMAGES_INIT=cf-images-init
IMAGES_RUN=cf-images-run

IMAGES_DIR=${DIR}/cfimages
mkdir -p $IMAGES_DIR

IMAGES_INIT_SAVE=""
while read image; do
  docker pull ${image}
  IMAGES_INIT_SAVE="${IMAGES_INIT_SAVE} $image"
done < $IMAGES_INIT
echo docker save -o ${IMAGES_DIR}/${IMAGES_INIT}.tar ${IMAGES_INIT_SAVE}
docker save -o ${IMAGES_DIR}/${IMAGES_INIT}.tar ${IMAGES_INIT_SAVE}


IMAGES_RUN_SAVE=""
while read image; do
  docker pull ${image}
  IMAGES_RUN_SAVE="${IMAGES_RUN_SAVE} $image"
done < $IMAGES_RUN
echo docker save -o ${IMAGES_DIR}/${IMAGES_RUN}.tar ${IMAGES_RUN_SAVE}
docker save -o ${IMAGES_DIR}/${IMAGES_RUN}.tar ${IMAGES_RUN_SAVE}
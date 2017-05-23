#!/bin/sh

set -e

for f in *.tar; do
  docker load < $f
done
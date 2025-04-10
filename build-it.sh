#!/bin/sh
#

docker buildx build --push --platform linux/amd64 -t drewmoseley/yocto-docker:22.04 .
docker buildx build --push --platform linux/arm64 -t drewmoseley/yocto-docker:22.04 .

#!/bin/sh
#

docker buildx build --push --platform linux/amd64,linux/arm64 -t drewmoseley/yocto-docker:22.04 .

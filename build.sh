#!/bin/bash

set -euo pipefail

if ! buildah images localhost/abuilder; then
    ./create-abuild-container.sh
fi

podman run \
    --privileged \
    --ipc=host \
    --pid=host \
    --net=host \
    -it \
    --rm \
    -v`pwd`:`pwd` \
    -w `pwd` \
    --entrypoint=./gen-img.sh \
    -e env_arch=armv7 \
    -e env_profile_name=net_rpi \
    localhost/abuilder

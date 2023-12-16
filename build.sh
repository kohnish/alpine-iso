#!/bin/bash

set -euo pipefail

profile=net_rpi
out_dir=`readlink -f out`

rpi_arch=${1:-armv7}
profile=${2:-net_rpi}
container_arch_opt=""
if [[ `arch` == "x86_64" ]] && [[ $rpi_arch == "armv7" ]]; then
    container_arch_opt='--arch arm'
fi

if ! buildah images localhost/abuilder-$rpi_arch; then
    buildah_run_cmd="buildah run"
    ctr=$(buildah from $container_arch_opt docker.io/library/alpine:edge)

    trap cleanup EXIT
    cleanup() {
        buildah rm $ctr
    }

    $buildah_run_cmd $ctr /bin/sh -c 'apk upgrade --no-cache && \
    apk add alpine-sdk build-base apk-tools alpine-conf busybox fakeroot grub xorriso squashfs-tools sudo bash dropbear tar gzip && \
    echo "/root/abuild.key" | abuild-keygen -i -a && \
    git clone --depth=1 https://gitlab.alpinelinux.org/alpine/aports.git
    '
    buildah commit $ctr abuilder-$rpi_arch
fi

podman run \
       $container_arch_opt \
       --privileged \
       --ipc=host \
       --pid=host \
       --net=host \
       -it \
       --rm \
       -v`pwd`:`pwd` \
       -w `pwd` \
       --entrypoint=./entrypoint.sh \
       -e env_arch=$rpi_arch \
       -e env_profile_name=$profile \
       -e env_tag=edge \
       -e env_out_dir=$out_dir \
       localhost/abuilder-$rpi_arch

#!/bin/bash
set -euo pipefail

buildah_run_cmd="buildah run"
ctr=$(buildah from docker.io/library/alpine:edge)

trap cleanup EXIT
cleanup() {
    buildah rm $ctr
}

$buildah_run_cmd $ctr /bin/sh -c 'apk upgrade --no-cache && \
    apk add grub grub-efi alpine-sdk build-base apk-tools alpine-conf busybox fakeroot syslinux xorriso squashfs-tools sudo bash dropbear && \
    echo "/root/abuild.key" | abuild-keygen -i -a && \
    git clone --depth=1 https://gitlab.alpinelinux.org/alpine/aports.git
    '
buildah commit $ctr abuilder

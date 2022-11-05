#!/bin/bash
set -euo pipefail

build_rpi_blobs() {
    curl -L https://dl-cdn.alpinelinux.org/alpine/edge/main/armv7/raspberrypi-bootloader-1.20221018-r0.apk |tar -C "${DESTDIR}" -zx --strip=1 boot/ || return 1
    curl -L https://dl-cdn.alpinelinux.org/alpine/edge/main/armv7/raspberrypi-bootloader-common-1.20221018-r0.apk |tar -C "${DESTDIR}" -zx --strip=1 boot/ || return 1
}

profile_net_rpi() {
    profile_rpi
    apks="alpine-base dropbear"
    hostname="rpi"
    apkovl=apkovl.net_rpi.sh
}

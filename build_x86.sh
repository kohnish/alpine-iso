#!/bin/bash

set -euo pipefail

if ! buildah images localhost/abuilder; then
    ./create-abuild-container.sh
fi

# alacritty
# alpine-base
# alsa-utils
# alsaconf
# doas
# eudev
# firefox
# font-dejavu
# font-ipa
# git
# grep
# intel-media-driver
# iwd
# linux-firmware
# mesa-dri-gallium
# mesa-va-gallium
# openssh-client
# openssh-server
# openssl
# seatd
# sof-firmware
# sway
# udev-init-scripts
# udev-init-scripts-openrc
# vim
# zsh
# zsh-vcs

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
    -e env_arch=x86_64 \
    -e env_profile_name=net_x86 \
    localhost/abuilder

#!/bin/bash

set -euo pipefail

# Config
out_dir=`pwd`/out

# Apk from a different arch fails without replacing the keys...
alpine_key_pkg=alpine-keys-2.4-r1.apk
curl -L https://dl-cdn.alpinelinux.org/alpine/edge/main/$env_arch/$alpine_key_pkg -o /var/tmp/key.apk
apk add /var/tmp/key.apk --allow-untrusted

# Place custom profiles
cp -p profiles/* /aports/scripts/

# Generate the image
export APORTS=""
export REPOS=""
export EXTRAREPOS=""
export WORKDIR=""

export _yaml=""
export _yaml_out=""
export quiet=""
export uboot_install=""
export modloop_addons=""
export kernel_addons=""
export modloopfw=""
export boot_addons=""
export image_name=""
export output_filename=""
export output_format=""

cd /aports/scripts
sh ./mkimage.sh \
    --tag edge \
    --outdir $out_dir \
    --arch $env_arch \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    --profile $env_profile_name

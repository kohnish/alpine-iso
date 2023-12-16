#!/bin/bash

set -euo pipefail

# Place custom profiles
cp -p profiles/* /aports/scripts/

# Generate the image
export APORTS=""
export REPOS="http://dl-cdn.alpinelinux.org/alpine/${env_tag}/main"
export REPOS_FILE="/etc/apk/repositories"
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
./mkimage.sh \
    --arch $env_arch \
    --outdir $env_out_dir \
    --profile $env_profile_name

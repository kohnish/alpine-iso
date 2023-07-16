#!/bin/bash
set -euo pipefail

profile_net_x86() {
    profile_standard
    apks="alpine-base dropbear"
    hostname="linux"
    boot_addons="amd-ucode intel-ucode"
    initrd_ucode="/boot/amd-ucode.img /boot/intel-ucode.img"
    apkovl="apkovl.net_x86.sh"
    syslinux_serial=""
    kernel_cmdline=""
    iso_opts=""
}

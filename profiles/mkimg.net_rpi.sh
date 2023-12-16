#!/bin/bash
set -euo pipefail

profile_net_rpi() {
    profile_rpi
    apks="alpine-base dropbear"
    hostname="rpi"
    apkovl=apkovl.net_rpi.sh
}

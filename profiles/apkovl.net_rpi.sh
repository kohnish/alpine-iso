#!/bin/bash

set -euo pipefail

HOSTNAME="$1"
if [ -z "$HOSTNAME" ]; then
    echo "usage: $0 hostname"
    exit 1
fi

cleanup() {
    rm -rf "$tmp"
}

makefile() {
    OWNER="$1"
    PERMS="$2"
    FILENAME="$3"
    cat > "$FILENAME"
    chown "$OWNER" "$FILENAME"
    chmod "$PERMS" "$FILENAME"
}

rc_add() {
    mkdir -p "$tmp"/etc/runlevels/"$2"
    ln -sf /etc/init.d/"$1" "$tmp"/etc/runlevels/"$2"/"$1"
}

tmp="$(mktemp -d)"
trap cleanup EXIT

mkdir -p "$tmp"/etc
makefile root:root 0644 "$tmp"/etc/hostname <<EOF
$HOSTNAME
EOF

mkdir -p "$tmp"/etc/network
makefile root:root 0644 "$tmp"/etc/network/interfaces <<EOF
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet static
        address 192.168.2.10
        netmask 255.255.255.0
        gateway 192.168.2.1
EOF

makefile root:root 0644 "$tmp"/etc/resolv.conf <<EOF
nameserver 8.8.8.8
EOF

mkdir -p "$tmp"/etc/apk
makefile root:root 0644 "$tmp"/etc/apk/world <<EOF
alpine-base
dropbear
EOF

makefile root:root 0644 "$tmp"/etc/apk/repositories <<EOF
http://dl-cdn.alpinelinux.org/alpine/edge/main
http://dl-cdn.alpinelinux.org/alpine/edge/community
https://dl-cdn.alpinelinux.org/alpine/edge/testing
EOF

mkdir -p "$tmp"/etc/conf.d
makefile root:root 0644 "$tmp"/etc/conf.d/dropbear <<EOF
DROPBEAR_OPTS="-B -a"
EOF

mkdir -p "$tmp"/etc/dropbear
/usr/bin/dropbearkey -t dss -f "$tmp"/etc/dropbear/dropbear_dss_host_key
/usr/bin/dropbearkey -t rsa -f "$tmp"/etc/dropbear/dropbear_rsa_host_key
/usr/bin/dropbearkey -t ecdsa -f "$tmp"/etc/dropbear/dropbear_ecdsa_host_key
/usr/bin/dropbearkey -t ed25519 -f "$tmp"/etc/dropbear/dropbear_ed25519_host_key
chmod 0644 "$tmp"/etc/dropbear/dropbear_dss_host_key
chmod 0644 "$tmp"/etc/dropbear/dropbear_rsa_host_key
chmod 0644 "$tmp"/etc/dropbear/dropbear_ecdsa_host_key
chmod 0644 "$tmp"/etc/dropbear/dropbear_ed25519_host_key
chown root:root "$tmp"/etc/dropbear/dropbear_dss_host_key
chown root:root "$tmp"/etc/dropbear/dropbear_rsa_host_key
chown root:root "$tmp"/etc/dropbear/dropbear_ecdsa_host_key
chown root:root "$tmp"/etc/dropbear/dropbear_ed25519_host_key

mkdir -p "$tmp"/etc/profile.d
makefile root:root 0655 "$tmp"/etc/profile.d/net_rpi_common.sh <<"EOF"
#/bin/sh
if [[ $USER == "root" ]]; then
    export LBU_MEDIA=mmcblk0p1
    export TMPDIR=/mnt

    if [[ ! -L "/etc/apk/cache" ]]; then
        setup-apkcache /media/mmcblk0p1/cache
    fi
fi
EOF

makefile root:root 0644 "$tmp"/etc/fstab <<EOF
/dev/mmcblk0p1 /media/mmcblk0p1 vfat ro,noatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,errors=remount-ro 0 0
/dev/mmcblk0p2 /mnt ext4 rw,noatime,nofail 0 0
EOF

printf '' > "$tmp"/etc/motd

rc_add devfs sysinit
rc_add dmesg sysinit
rc_add mdev sysinit
rc_add hwdrivers sysinit
rc_add modloop sysinit
rc_add networking sysinit
rc_add dropbear sysinit

rc_add hwclock boot
rc_add modules boot
rc_add sysctl boot
rc_add hostname boot
rc_add bootmisc boot
rc_add syslog boot

rc_add mount-ro shutdown
rc_add killprocs shutdown
rc_add savecache shutdown

tar -c -C "$tmp" etc | gzip -9n > $HOSTNAME.apkovl.tar.gz

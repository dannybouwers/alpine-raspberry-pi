#!/bin/sh

set -xe

TARGET_HOSTNAME="raspberrypi"
TARGET_PASSWORD="changeme"
TARGET_TIMEZONE="Europe/Amsterdam"
TARGET_LOCALE="us-us"
LAYOUT=$(echo $LOCALE | cut -d'-' -f 1);
LAYOUT_SPEC=$(echo $LOCALE | cut -d'-' -f 2);


# base stuff
apk add --no-cache ca-certificates alpine-conf
update-ca-certificates

# password
echo "root:${TARGET_PASSWORD}" | chpasswd

# hostname
setup-hostname "${TARGET_HOSTNAME}"

# keymap
setup-keymap "${LAYOUT}" "${LAYOUT_SPEC}"

# time
setup-timezone -z "${TARGET_TIMEZONE}"
apk add --no-cache chrony
rc-update --quiet add swclock boot
rc-update --quiet add chronyd default

# device manager
if rc-service --exists mdev ; then
    rc-service --ifstarted mdev stop
    rc-update --quiet delete mdev sysinit || :
fi
apk add mdevd mdevd-openrc
rc-update --quiet add mdevd sysinit
rc-update --quiet add mdevd-init sysinit
rc-update --quiet add hwdrivers sysinit

# message of the day
cat > /etc/motd <<EOF
Welcome to Alpine!

The Alpine Wiki contains a large amount of how-to guides and general
information about administrating Alpine systems.
See <http://wiki.alpinelinux.org>.

This is an unofficial image. Issues can be reported at 
https://github.com/dannybouwers/alpine-images/issues

You may change this message by editing /etc/motd.
EOF

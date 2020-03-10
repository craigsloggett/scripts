#!/usr/bin/env bash

#
# setup_base_system.sh
#

echo 'Generating base system profile scripts, must be run as root.'

cp -v ./etc/profile.d/xdg-base-system-directories.sh /etc/profile.d/
chmod 644 /etc/profile.d/xdg-base-system-directories.sh

cp -v ./etc/profile.d/xdg-base-user-directories.sh /etc/profile.d/
chmod 644 /etc/profile.d/xdg-base-user-directories.sh

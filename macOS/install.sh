#!/bin/sh

SSH_KEYFILE="${HOME}/.ssh/id_ed25519"

mkdir -p ~/Developer

if [ ! -f "${SSH_KEYFILE}" ]; then
  ssh-keygen -q -t ed25519 -f "${SSH_KEYFILE}" -N ''
fi

# Turn on the firewall
/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
# Enable stealth mode
/usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
# Remove the applications listed by default in Sequoia from the firewall
/usr/libexec/ApplicationFirewall/socketfilterfw --remove /usr/libexec/remoted
/usr/libexec/ApplicationFirewall/socketfilterfw --remove /usr/bin/python3
/usr/libexec/ApplicationFirewall/socketfilterfw --remove /usr/bin/ruby
/usr/libexec/ApplicationFirewall/socketfilterfw --remove /usr/sbin/cupsd
/usr/libexec/ApplicationFirewall/socketfilterfw --remove /usr/libexec/sharingd
/usr/libexec/ApplicationFirewall/socketfilterfw --remove /usr/libexec/sshd-keygen-wrapper
/usr/libexec/ApplicationFirewall/socketfilterfw --remove /usr/sbin/smbd

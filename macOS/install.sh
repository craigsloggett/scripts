#!/bin/sh

# Create a Developer directory
mkdir -p ~/Developer

# Create an SSH key pair
SSH_KEYFILE="${HOME}/.ssh/id_ed25519"

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

# Enable software update settings
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool true
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool true
sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool true
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool true
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall -bool true
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutoUpdate -bool true
sudo softwareupdate --schedule on >/dev/null 2>&1

# Disable Fast User Switching in the menu bar
sudo defaults write /Library/Preferences/.GlobalPreferences MultipleSessionEnabled -bool false

# Reload the SystemUIServer to apply the settings immediately
killall SystemUIServer

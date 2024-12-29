#!/bin/sh

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Prompt the user for the desired hostname (use a default if non-interactive)
if [ -t 0 ]; then
  echo "Please enter the desired hostname: "
  read -r hostname
else
  hostname="macOS"
fi

# Validate the input (ensure it's not empty)
if [ -z "${hostname}" ]; then
  echo "Hostname cannot be empty. Please run the script again."
  exit 1
fi

# Set computer name (as done via System Preferences → Sharing)
sudo scutil --set ComputerName "${hostname}"
sudo scutil --set HostName "${hostname}"
sudo scutil --set LocalHostName "${hostname}"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "${hostname}"

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
defaults write -g MultipleSessionEnabled -bool false

# Don't show the Spotlight icon in the menu bar
defaults -currentHost write com.apple.Spotlight MenuItemHidden -bool true

# Configure the keyboard settings
defaults write -g InitialKeyRepeat -int 25
defaults write -g KeyRepeat -int 2

# Clear the Dock
defaults write com.apple.dock persistent-apps -array

# Add applications to the Dock

# Set the icon size of Dock items to 46 pixels
defaults write com.apple.dock tilesize -int 46

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Restart the Dock to apply changes
killall Dock

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

sudo reboot

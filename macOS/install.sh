#!/bin/sh

# Globally disable globbing and enable exit-on-error.
set -ef

# Defaults for environment variables.
: "${COMPUTER_NAME:?Please set the COMPUTER_NAME environment variable and run the script again.}"

# Ask for the administrator password upfront
sudo -v

# Set computer name (as done via System Preferences → Sharing)
sudo scutil --set ComputerName "${COMPUTER_NAME}"
sudo scutil --set HostName "${COMPUTER_NAME}"
sudo scutil --set LocalHostName "${COMPUTER_NAME}"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "${COMPUTER_NAME}"

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

# Check if FileVault is already enabled
fv_status=$(fdesetup status)
if echo "$fv_status" | grep -q "FileVault is Off"; then
  # Enable FileVault
  sudo fdesetup enable -user "$(whoami)" | tee ~/Desktop/"FileVault Recovery Key.txt"
fi

sudo reboot

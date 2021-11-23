#!/bin/sh
#
# setup.sh - macOS installation shell script.

# Helper Functions

generate_dock_app_entry() {
  # Return the configuration required to add an app to the Dock.
  app_name="$1"
  app_path=""

  # Most apps are in /Applications with the exception of what is
  # listed here.
  case "${app_name}" in
    Mail)
      app_path="/System/Applications"
      ;;
    Calendar)
      app_path="/System/Applications"
      ;;
    Reminders)
      app_path="/System/Applications"
      ;;
    Notes)
      app_path="/System/Applications"
      ;;
    Terminal)
      app_path="/System/Applications/Utilities"
      ;;
    *)
      app_path="/Applications"
      ;;
  esac

  printf '<dict>
            <key>tile-data</key>
              <dict>
                <key>file-data</key>
                  <dict>
                    <key>_CFURLString</key><string>/%s/%s.app</string>
                    <key>_CFURLStringType</key><integer>0</integer>
                  </dict>
              </dict>
          </dict>' "${app_path}" "${app_name}"
}

# Prepare the OS

capitalize_username() {
  :  # This can't be automated as far as I can tell.
}

add_source_directory() {
  mkdir -p "${HOME}/Source"
}

install_homebrew() {
  # Homebrew (taken from their website)
  # https://brew.sh/
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

# Command Line Utilities

configure_ssh() {
  ssh_key_filename="${SSH_KEY_FILENAME:-id_ed25519}"

  if [ ! -f "${HOME}/.ssh/${ssh_key_filename}" ]; then
    ssh-keygen -f "${HOME}/.ssh/${ssh_key_filename}" -t ed25519 -q -N ""
  fi

  # Copy the public SSH key to my server.
  # TODO: Automate this process.
  printf '%s\n' "Distribute the public key now. I'll wait."
  read -r
}

setup_gnupg() {
  export GNUPGHOME="${XDG_DATA_HOME:=$HOME/.local/share}/gnupg"
  gpg_key_filename="${GPG_KEY_FILENAME:-gpg-user.key}"

  # Install gnupg with Homebrew.
  if [ ! -f /usr/local/bin/gpg ]; then
    brew install gnupg
  fi

  # Copy the GPG keys from my server.
  # TODO: Automate this process.
  while [ ! -f "${HOME}/Downloads/${gpg_key_filename}" ]; do
    printf '%s\n' "Download the relevant GPG keys and put them in: \
                   ${HOME}/Downloads/${gpg_key_filename}"
    read -r 
  done

  # Setup the GPG directory.
  mkdir -p "$GNUPGHOME"
  chmod 700 "$GNUPGHOME"

  # Import the GPG keys.
  gpg --import "${HOME}/Downloads/${gpg_key_filename}"

  # Set the trust level on the GPG keys.
  printf '%s\n' "Set the trust level of the imported keys: gpg --edit-key <KEY>"
  read -r
}

setup_pass() {
  export PASSWORD_STORE_DIR="${XDG_DATA_HOME:=$HOME/.local/share}/pass"

  if [ ! -f /usr/local/bin/pass ]; then
    brew install pass
  fi

  if [ ! -d "${PASSWORD_STORE_DIR}" ]; then
    printf '%s\n' "Clone the password store repository to: \
                   ${PASSWORD_STORE_DIR}"
    read -r
  fi
}

# Login to the appropriate accounts.

login_apple_id() {
  :  # This can't be automated as far as I can tell.
}

login_exchange() {
  :  # This can't be automated as far as I can tell.
}

# The following functions encapsulate the System Preferences by the same name.

configure_dock_and_menu_bar() {
  # Adjust the size of the Docker
  defaults write com.apple.dock tilesize -float 48.0
  # Uncheck "Show recent applications in Dock"
  defaults write com.apple.dock show-recents -bool false

  # Cleanup the Dock items
  defaults delete com.apple.dock persistent-apps

  # Remove the Downloads folder and recent apps from the Dock
  defaults delete com.apple.dock persistent-others
  defaults delete com.apple.dock recent-apps

  # Configure which applications are in the Dock in a declarative way.
  defaults write com.apple.dock persistent-apps -array-add "$(generate_dock_app_entry "Firefox")"
  defaults write com.apple.dock persistent-apps -array-add "$(generate_dock_app_entry "Mail")"
  defaults write com.apple.dock persistent-apps -array-add "$(generate_dock_app_entry "Calendar")"
  defaults write com.apple.dock persistent-apps -array-add "$(generate_dock_app_entry "Reminders")"
  defaults write com.apple.dock persistent-apps -array-add "$(generate_dock_app_entry "Notes")"
  defaults write com.apple.dock persistent-apps -array-add "$(generate_dock_app_entry "Terminal")"
}

configure_spotlight() {
  # Reboot required for all settings to take affect.

  # To get the 'Source' option in Spotlight
  touch /Applications/Xcode.app

  # I'm pretty sure a reboot is required before writing the settings to disable 'Source'.

  defaults write com.apple.spotlight orderedItems -array \
    '{"enabled" = 1;"name" = "APPLICATIONS";}' \
   	'{"enabled" = 0;"name" = "BOOKMARKS";}' \
   	'{"enabled" = 1;"name" = "MENU_EXPRESSION";}' \
   	'{"enabled" = 0;"name" = "CONTACT";}' \
   	'{"enabled" = 1;"name" = "MENU_CONVERSION";}' \
   	'{"enabled" = 1;"name" = "MENU_DEFINITION";}' \
   	'{"enabled" = 0;"name" = "DOCUMENTS";}' \
   	'{"enabled" = 0;"name" = "EVENT_TODO";}' \
   	'{"enabled" = 1;"name" = "DIRECTORIES";}' \
   	'{"enabled" = 1;"name" = "FONTS";}' \
   	'{"enabled" = 0;"name" = "IMAGES";}' \
   	'{"enabled" = 0;"name" = "MESSAGES";}' \
   	'{"enabled" = 0;"name" = "MOVIES";}' \
   	'{"enabled" = 0;"name" = "MUSIC";}' \
   	'{"enabled" = 0;"name" = "MENU_OTHER";}' \
   	'{"enabled" = 0;"name" = "PDF";}' \
   	'{"enabled" = 0;"name" = "PRESENTATIONS";}' \
   	'{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}' \
   	'{"enabled" = 0;"name" = "SPREADSHEETS";}' \
   	'{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
   	'{"enabled" = 0;"name" = "SOURCE";}' \
   	'{"enabled" = 0;"name" = "MENU_WEBSEARCH";}'

  # Once rebooted, rebuild the index from scratch.
  # sudo mdutil -E
}

configure_passwords() {
  :  # Disable "Detect compromised passwords".
}

configure_security_and_privacy() {
  # TODO: Handle this to be idempotent

  # Turn on Firewall
  defaults write /Library/Preferences/com.apple.alf globalstate -int 1
  # Turn on FileVault
  sudo fdesetup enable
}

configure_software_update() {
  # Check 'Automatically keep my Mac up to date'
  defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
  # Check everything under 'Advanced'
  defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticDownload -bool true
  defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool true
  defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool true
  defaults write /Library/Preferences/com.apple.commerce ConfigDataInstall -bool true
  defaults write /Library/Preferences/com.apple.commerce CriticalUpdateInstall -bool true
}

configure_bluetooth() {
  # Check "Show Bluetooth in menu bar"
  defaults -currentHost write com.apple.controlcenter Sound -int 18
}

configure_sound() {
  # Check "Show Sound in menu bar: Always"
  defaults -currentHost write com.apple.controlcenter Sound -int 18
}

configure_keyboard() {
  # Logout / Login required for all settings to take affect.

  # Update Key Repeat to the fastest setting
  defaults write -g KeyRepeat -int 2
  # Update Delay Until Repeat to the second from the shortest setting
  defaults write -g InitialKeyRepeat -int 25
  # Touch Bar shows "Expanded Control Strip"
  defaults write com.apple.touchbar.agent PresentationModeGlobal -string "fullControlStrip"
  # Press fn key to "Show Emoji & Symbols"
  defaults write com.apple.HIToolbox AppleFnUsageType -int 2
}

configure_displays() {
  :  #
}

configure_mouse() {
  :  #
}

configure_battery() {
  # Check "Prevent your Mac from automatically sleeping when the display is off"
  sudo pmset -c sleep 0
}

# Application Preferences

configure_finder() {
  # Update "New Finder windows show:" to Home
  defaults write com.apple.finder NewWindowTarget -string "PfHm"
  defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
  # Show Status Bar
  defaults write com.apple.finder ShowStatusBar -bool true
  # Show Path Bar
  defaults write com.apple.finder ShowPathbar -bool true
  # Avoid creating .DS_Store files on network or USB volumes
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
}

configure_safari() {
  :  #
}

configure_textedit() {
  :  #
}

configure_mail() {
  :  #
}

configure_calendar() {
  :  #
}

setup_firefox() {
  :  # Check if Pass is setup.
  :  # Install Firefox with Homebrew.
  :  # Open Firefox to create a profile directory then close it.
  :  # Download a user.js file from the dotfiles repository.
  :  # Copy the user.js file to the Firefox profile directory.
  # The rest can't be automated as far as I can tell.
  :  # Login to Sync
  :  # Turn syncing on only for Bookmarks.
}

clone_dotfiles_repository() {
  :  # Check if Firefox is setup.
  # This can't be automated as far as I can tell.
  :  # Login to GitHub and add the public SSH key to my account.
  # The rest is automated.
  :  # Clone the dotfiles repository to the ~/Source directory via SSH.
}

configure_zsh() {
  :  # Create the XDG directories.
  :  # Create /etc/zshenv to export ZDOTDIR
  :  # Symlink ZSH configuration.
  :  # Cleanup ZSH files left over from fresh install.
}

# Cleanup Items

import_terminal_profile() {
  :  # This can't be automated as far as I can tell.
}

configure_vim() {
  :  # Create the cache and data directories.
  :  # Symlink Vim configuration.
  :  # Cleanup Vim files left over from fresh install.
}

configure_git() {
  :  # Symlink Git configuration.
  :  # Create a config-personal file with email and signing key configured.
}

configure_gnupg() {
  :  # Symlink GnuPG configuration.
}

configure_less() {
  :  # Create the Less history directory.
  :  # Cleanup Less files left over from fresh install.
}

# Additional Applications

setup_rectangle() {
  :  # Install Rectangle with Homebrew (Cask)
  :  # Configure the application.
}

main() {
  # Globally enable exit-on-error and require variables to be set.
  set -o errexit
  set -o nounset

#  capitalize_username
#  add_source_directory
#  install_homebrew
#  login_apple_id
#  login_exchange
#
#  configure_dock_and_menu_bar
#  configure_spotlight
#  configure_passwords
#  configure_security_and_privacy
#  configure_software_update
#  configure_bluetooth
#  configure_sound
#  configure_keyboard
#  configure_displays
#
#  configure_finder
#  configure_safari
#  configure_textedit
#  configure_mail
#  configure_calendar
#
#  configure_ssh
#  setup_gnupg
#  setup_pass
#  setup_firefox
#  clone_dotfiles_repository
#  configure_zsh
#
#  import_terminal_profile
#  configure_vim
#  configure_git
#  configure_gnupg
#  configure_less
#
#  setup_rectangle
}

main "$@"


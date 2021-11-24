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

setup_xdg_directories() {
  # Export the XDG environment variables if they aren't already.
  export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
  export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
  export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
  export XDG_BIN_HOME="${XDG_BIN_HOME:-${HOME}/.local/bin}"
  export XDG_LIB_HOME="${XDG_LIB_HOME:-${HOME}/.local/lib}"

  # Create all directories.
  mkdir -p "$XDG_CONFIG_HOME"
  mkdir -p "$XDG_CACHE_HOME"
  mkdir -p "$XDG_DATA_HOME"
  mkdir -p "$XDG_BIN_HOME"
  mkdir -p "$XDG_LIB_HOME"
}

add_source_directory() {
  source_directory="${SOURCE_DIRECTORY:-${HOME}/Source}"
    mkdir -p "${source_directory}"
}

install_homebrew() {
  # Homebrew (taken from their website)
  # https://brew.sh/
  brew_url="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
  if ! command -v brew > /dev/null; then
    /bin/bash -c "$(curl -fsSL ${brew_url})"
  fi
}

# Command Line Utilities

configure_ssh() {
  ssh_key_filename="${SSH_KEY_FILENAME:-id_ed25519}"

  if [ ! -f "${HOME}/.ssh/${ssh_key_filename}" ]; then
    ssh-keygen -f "${HOME}/.ssh/${ssh_key_filename}" -t ed25519 -q -N ""
  fi

  # Copy the public SSH key to my server.
  # TODO: Automate this process.
  printf '%s\n' "Distribute the public key now."
  read -r
}

setup_gnupg() {
  export GNUPGHOME="${XDG_DATA_HOME:-${HOME}/.local/share}/gnupg"

  # Configuration Options
  gpg_public_key="${GPG_PUBLIC_KEY:-23BF43EF}"
  gpg_key_filename="${GPG_KEY_FILENAME:-secret-subkeys.gpg}"

  # Install gnupg with Homebrew.
  if ! command -v gpg > /dev/null; then
    brew install gnupg
  fi

  # Setup the GPG directory.
  mkdir -p "$GNUPGHOME"
  chmod 700 "$GNUPGHOME"

  # Copy the GPG keys from my server.
  # TODO: Automate this process.
  printf '%s %s\n' "Download the relevant GPG keys and put them in:" \
                   "${HOME}/Downloads/${gpg_key_filename}"
  read -r 

  # Import the GPG keys if not imported already.
  if ! gpg -k | grep -q "${gpg_public_key}"; then
    gpg --import "${HOME}/Downloads/${gpg_key_filename}"
  fi

  # Set the trust level on the GPG keys if not set.
  if gpg -k | grep 'uid' | grep -q 'unknown'; then
    printf '%s %s\n' "Set the trust level of the imported keys:" \
                     "gpg --edit-key ${gpg_public_key}"
    read -r
  fi
}

setup_pass() {
  export PASSWORD_STORE_DIR="${XDG_DATA_HOME:=${HOME}/.local/share}/pass"

  if ! command -v gpg > /dev/null; then
    :  # GnuPG being configured is a requirement.
    :  # TODO: Decide what to do if this requirement is not met.
  fi

  if ! command -v pass > /dev/null; then
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

configure_security_and_privacy() {
  # Turn on Firewall
  sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
  # Turn on FileVault
  if sudo fdesetup status | grep -q 'FileVault is Off.'; then
    printf '%s\n' "Enabling FileVault, please follow the prompts:"
    sudo fdesetup enable
  fi
}

configure_software_update() {
  # Check 'Automatically keep my Mac up to date'
  sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
  # Check everything under 'Advanced'
  sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate.plist AutomaticDownload -bool true
  sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool true
  sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool true
  sudo defaults write /Library/Preferences/com.apple.commerce ConfigDataInstall -bool true
  sudo defaults write /Library/Preferences/com.apple.commerce CriticalUpdateInstall -bool true
}

configure_bluetooth() {
  # Check "Show Bluetooth in menu bar"
  defaults -currentHost write com.apple.controlcenter Bluetooth -int 18
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
  # In order for defaults to behave correctly for Safari, you need to grant
  # Terminal Full Disk Access.

  # Add Terminal to "Full Disk Access" under Security & Privacy -> Privacy
  # https://github.com/mathiasbynens/dotfiles/issues/849#issuecomment-436697238
  printf '%s\n' "Add Terminal to \"Full Disk Access\" under Security & Privacy -> Privacy"
  osascript -e 'tell application "System Preferences" to reveal anchor "Privacy" of pane "com.apple.preference.security" activate'
  read -r

  # Start Page Settings
  # Uncheck all options except for "Privacy Report"
  defaults write com.apple.Safari ShowFavorites -bool false
  defaults write com.apple.Safari ShowFrequentlyVisitedSites -bool false
  defaults write com.apple.Safari ShowSiriSuggestionsPreference -bool false
  defaults write com.apple.Safari ShowReadingListInFavorites -bool false
  defaults write com.apple.Safari ShowBackgroundImageInFavorites -bool false

  # General
  # Remove history items: After one day
  defaults write com.apple.Safari HistoryAgeInDaysLimit -int 1
  # Remove download list items: When Safari quits
  defaults write com.apple.Safari DownloadsClearingPolicy -int 1
  # Uncheck "Open "safe" files after downloading".
  defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

  # AutoFill
  # Uncheck all AutoFill web forms options.
  defaults write com.apple.Safari AutoFillFromAddressBook -bool false
  defaults write com.apple.Safari AutoFillPasswords -bool false
  defaults write com.apple.Safari AutoFillCreditCardData -bool false
  defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false

  # Passwords
  # Uncheck "Detect compromised passwords"
  defaults write com.apple.Safari PasswordBreachDetectionOn -bool false
  # Search
  # Select DuckDuckGo as the Search engine
  defaults write com.apple.Safari SearchProviderShortName -string "DuckDuckGo"
  # Uncheck "Include search engine suggestions"
  defaults write com.apple.Safari SuppressSearchSuggestions -bool true
  # Uncheck all options in Smart Search Field except for "Show Favorites"
  defaults write com.apple.Safari WebsiteSpecificSearchEnabled -bool false
  defaults write com.apple.Safari PreloadTopHit -bool false
  # Security
  # Uncheck "Warn when visiting a fraudulent website"
  defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool false
  # Privacy
  # Check "Block all cookies"
  defaults write com.apple.Safari BlockStoragePolicy -int 2
  # Uncheck "Allow websites to check for Apple Pay and Apple Card
  defaults write com.apple.Safari WebKitPreferences.applePayCapabilityDisclosureAllowed -bool false
  # Uncheck "Allow privacy-preserving measurements of ad effectiveness"
  defaults write com.apple.Safari WebKitPreferences.privateClickMeasurementEnabled -bool false
  # Advanced
  # Check "Show full website address"
  defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true
}

configure_textedit() {
  # Select "Plain Text"
  defaults write com.apple.TextEdit RichText -bool false
  # Uncheck all "Options"
  defaults write com.apple.TextEdit CheckSpellingWhileTyping -bool false
  defaults write com.apple.TextEdit CorrectSpellingAutomatically -bool false
  defaults write com.apple.TextEdit ShowRuler -bool false
  defaults write com.apple.TextEdit SmartSubstitutionsEnabledInRichTextOnly -bool false
  defaults write com.apple.TextEdit SmartCopyPaste -bool false
  defaults write com.apple.TextEdit SmartQuotes -bool false
  defaults write com.apple.TextEdit SmartDashes -bool false
  defaults write com.apple.TextEdit TextReplacement -bool false
  # Uncheck "Add ".txt" extension to plain text files"
  defaults write com.apple.TextEdit AddExtensionToNewPlainTextFiles -bool false
  # Check "Display HTML files as HTML code instead of formatted text"
  defaults write com.apple.TextEdit IgnoreHTML -bool true
}

configure_mail() {
  :  #
}

configure_calendar() {
  :  #
}

setup_firefox() {
  if ! command -v pass > /dev/null; then
    :  # Passwords are needed to setup Firefox.
    :  # TODO: Decide what to do if this requirement is not met.
  fi

  # Install Firefox with Homebrew.
  if [ ! -d /Applications/Firefox.app ]; then
    brew install --cask firefox
  fi  

  # Firefox must be run once before the default-release folder is generated.
  if [ ! -d "${HOME}/Library/Application Support/Firefox/Profiles/" ]; then
  	printf '%s\n' "Opening Firefox to generate the default-release folder."
    /Applications/Firefox.app/Contents/MacOS/./firefox &
		printf '%s\n'	"Waiting 10 seconds before closing automatically..."
    sleep 10
    kill -9 "$(pgrep firefox)"
    sleep 5
  fi  

  # Copy the user.js to the Firefox directory....
  # TODO: do this automatically.

  # The rest can't be automated as far as I can tell.
  :  # Login to Sync
  :  # Turn syncing on only for Bookmarks.
}

clone_dotfiles_repository() {
  ssh_key_filename="${SSH_KEY_FILENAME:-id_ed25519}"
	source_directory="${SOURCE_DIRECTORY:-${HOME}/Source}"
	dotfiles_repository="${DOTFILES_REPOSITORY:-github.com:nerditup/dotfiles.git}"

  if ! command -v git > /dev/null; then
    :  # Git is required to clone the dotfiles.
    :  # TODO: Decide what to do if this requirement is not met.
  fi

  if ! command -v pass > /dev/null; then
    :  # Passwords are required to login to GitHub.
    :  # TODO: Decide what to do if this requirement is not met.
  fi

  if [ ! -f "${HOME}/.ssh/${ssh_key_filename}" ]; then
		:  # An SSH key is required to clone the dotfiles.
    :  # TODO: Decide what to do if this requirement is not met.
	fi

  if [ ! -d /Applications/Firefox.app ]; then
    :  # Firefox is needed to add an SSH key to GitHub.
    :  # TODO: Decide what to do if this requirement is not met.
  fi  

	pbcopy < "${HOME}/.ssh/${ssh_key_filename}.pub"
	printf '%s\n' "Public SSH key copied to the clipboard."

  # Login to GitHub and add the public SSH key to my account.
  # TODO: Automate this process.
  printf '%s\n' "Login to GitHub and add the public SSH key to your account."
  read -r

  case "${dotfiles_repository}" in
    *github*)
      username="${dotfiles_repository##*github.com}"
      username="${username:1}"
      username="${username%%/*}"
      
      reponame="${dotfiles_repository##*/}"
      reponame="${reponame%%.git}"
      
      if [ ! -d "${source_directory}/GitHub/${username}/${reponame}" ]; then
        mkdir -p "${source_directory}/GitHub/${username}"
        git clone "${dotfiles_repository}" "${source_directory}/GitHub/${username}/${reponame}"
      fi
      ;;
    *)
      # Manually clone the dotfiles repository to the ~/Source directory.
      printf '%s\n' "Clone your dotfiles to the desired location."
      read -r
      ;;
  esac
}

configure_zsh() {
  # Create /etc/zshenv to export ZDOTDIR
  cat << 'EOF' | sudo tee /etc/zshenv
# /etc/zshenv: system-wide .zshenv file for zsh(1).
#
# This file is sourced on all invocations of the shell.
# If the -f flag is present or if the NO_RCS option is
# set within this file, all other initialization files
# are skipped.
#
# This file should contain commands to set the command
# search path, plus other important environment variables.
# This file should not contain commands that produce
# output or assume the shell is attached to a tty.
#
# Global Order: zshenv, zprofile, zshrc, zlogin

# ZSH Dot Directory
export ZDOTDIR="${HOME}/.config/zsh"
EOF

  chmod 755 /usr/local/share/zsh
  chmod 755 /usr/local/share/zsh/site-functions

  mkdir -p "${XDG_DATA_HOME}/zsh"

  :  # Symlink ZSH configuration.
  # TODO: Automate this process.

  # Cleanup ZSH files left over from fresh install.
  rm -f "${HOME}/.zsh_history"
  rm -rf "${HOME}/.zsh_sessions"
}

# Cleanup Items

import_terminal_profile() {
  :  # This can't be automated as far as I can tell.
}

configure_vim() {
  # Create the cache and data directories.
  mkdir -p "${XDG_CACHE_HOME:-${HOME}/.cache}/vim"
  mkdir -p "${XDG_DATA_HOME:-${HOME}/.local/share}/vim"

  :  # Symlink Vim configuration.
  # TODO: Automate this process.

  # Cleanup Vim files left over from fresh install.
  rm -f "${HOME}/.viminfo"
}

configure_git() {
  :  # Symlink Git configuration.
  # TODO: Automate this process.
  :  # Create a config-personal file with email and signing key configured.
  # TODO: Automate this process.
}

configure_gnupg() {
  :  # Symlink GnuPG configuration.
  # TODO: Automate this process.
}

configure_less() {
  # Create the Less history directory.
  mkdir -p "${XDG_DATA_HOME:-${HOME}/.local/share}/less"
  # Cleanup Less files left over from fresh install.
  rm -f "${HOME}/.lesshst"
}

# Additional Applications

setup_rectangle() {
  # Install Rectangle with Homebrew (Cask)
  if [ ! -d /Applications/Rectangle.app ]; then
    brew install --cask rectangle
  fi
  :  # Configure the application.
  # TODO: Automate this process.
}

main() {
  # Turn on Debugging Output
  export PS4=" -> + "
  set -x

  # Globally enable exit-on-error and require variables to be set.
  set -o errexit
  set -o nounset

  # Ask for the administrator password upfront.
  sudo -v

  # Keep-alive: update existing `sudo` time stamp until script has finished.
  while true; do 
    sudo -n true; sleep 60; kill -0 "$$" || exit; 
  done 2>/dev/null &

#  capitalize_username
  setup_xdg_directories
  add_source_directory
  install_homebrew
  configure_ssh
  setup_gnupg
  setup_pass

#  login_apple_id
#  login_exchange

# Security and Privacy settings require sudo.
  configure_security_and_privacy
# Security and Privacy settings require sudo.
  configure_software_update
  configure_bluetooth
  configure_sound
# Keyboard requires Logout/Login for all settings to take affect.
  configure_keyboard
#  configure_displays
#  configure_mouse
  configure_battery

  configure_finder
  configure_safari
  configure_textedit
#  configure_mail
#  configure_calendar

  setup_firefox
  clone_dotfiles_repository
  configure_zsh

#  import_terminal_profile
  configure_vim
  configure_git
  configure_gnupg
  configure_less

  setup_rectangle

# Dock requires applications to be installed first.
#  configure_dock_and_menu_bar
# Spotlight requires a reboot.
#  configure_spotlight
}

main "$@"


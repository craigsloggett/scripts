#!/bin/sh
#
# setup.sh - macOS installation shell script.

configuration() {
  # Setup configuration variables.
  export SOURCE_DIRECTORY="${SOURCE_DIRECTORY:-${HOME}/Source}"
  export SSH_KEY_FILENAME="${SSH_KEY_FILENAME:-id_ed25519}"
  export GPG_PUBLIC_KEY="${GPG_PUBLIC_KEY:-23BF43EF}"
  export GPG_KEY_FILENAME="${GPG_KEY_FILENAME:-secret-subkeys.gpg}"
  export DOTFILES_REPOSITORY="${DOTFILES_REPOSITORY:-github.com:nerditup/dotfiles.git}"
}

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
  # TODO: Add configuration for a username and only check for capitalization
  #       if needed.

  # Remove everything before the final forward-slash '/'.
  basename="${HOME##*/}"

  case "${basename}" in
    [!A-Z]*)
      printf '%s%s\n' "Your account name and home directory do not start " \
                      "with a capital: ${HOME}"

      osascript -e 'tell application "System Preferences" to activate'

      printf '%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n' \
                  'To update your account name and home directory:' \
                  ' 1. Create a new temporary "Administrator" account.' \
                  ' 2. Logout then login with the new temporary account.' \
                  ' 3. Open up "Users & Groups" in System Preferences.' \
                  ' 4. Right click your user, then click "Advanced Settings".' \
                  ' 5. Update "Account name" to have a capital letter.' \
                  ' 6. Update "Home directory" to have a capital letter.' \
                  ' 7. Rename the Home Directory to match the capital letter.' \
                  ' 8. Logout then login with your account.' \
                  ' 9. Delete the temporary account.'
      exit 1
    ;;

    *)
      :  # The username is capitalized, do nothing.
    ;;
  esac
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
  source_directory="${SOURCE_DIRECTORY}"
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
  ssh_key_filename="${SSH_KEY_FILENAME}"

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
  gpg_public_key="${GPG_PUBLIC_KEY}"
  gpg_key_filename="${GPG_KEY_FILENAME}"

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
  printf '%s\n' "Login to your Apple account."
  osascript -e 'tell application "System Preferences" to reveal pane "com.apple.preferences.AppleIDPrefPane" activate'
  read -r
}

login_exchange() {
  :  # This can't be automated as far as I can tell.
  printf '%s\n' "Login to your Exchange account."
  osascript -e 'tell application "System Preferences" to reveal pane "com.apple.preferences.internetaccounts" activate'
  read -r
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
  defaults write com.apple.dock persistent-apps -array-add "$(generate_dock_app_entry "Mail")"
  defaults write com.apple.dock persistent-apps -array-add "$(generate_dock_app_entry "Calendar")"
  defaults write com.apple.dock persistent-apps -array-add "$(generate_dock_app_entry "Reminders")"
  defaults write com.apple.dock persistent-apps -array-add "$(generate_dock_app_entry "Notes")"
  defaults write com.apple.dock persistent-apps -array-add "$(generate_dock_app_entry "Terminal")"
}

configure_spotlight() {
  # Reboot required for all settings to take affect.

  if ! defaults read com.apple.spotlight orderedItems | grep -q "SOURCE"; then
    # To get the 'Developer' option in Spotlight
    touch /Applications/Xcode.app
    # Open up the System Preferences application to make the option available in defaults.
    osascript -e 'tell application "System Preferences" to reveal pane "com.apple.preference.spotlight" activate'
  fi

  # ADD WAIT

  if ! defaults read com.apple.spotlight orderedItems | grep -B 1 "SOURCE" | grep -q "enabled = 0;"; then

    printf '%s\n' "Configuring Spotlight..."
    
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

    # Create a temporary script to rebuild the index from scratch.
    cat << 'EOF' > "${HOME}/Downloads/rebuild_spotlight_index.sh"
#!/bin/sh
#
# rebuild_spotlight_index.sh - Rebuild the Spotlight index from scratch.

# Globally enable exit-on-error and require variables to be set.
set -o errexit
set -o nounset

printf '%s\n' "Asking for sudo password to rebuild the Spotlight index:"

sudo mdutil -E

# Cleanup
rm -f "${HOME}/Downloads/rebuild_spotlight_index.sh"
rm -f "${HOME}/Library/LaunchAgents/com.apple.rebuildspotlightindex.plist"
EOF

    # Update the permissions of the script.
    chmod +x "${HOME}/Downloads/rebuild_spotlight_index.sh"

    # Create a launchd Agent to run a script after rebooting.
    mkdir -p "${HOME}/Library/LaunchAgents"  # launchd will be used to do things after rebooting.

    cat << EOF > "${HOME}/Library/LaunchAgents/com.apple.rebuildspotlightindex.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>com.apple.rebuildspotlightindex</string>
    <key>ProgramArguments</key>
    <array>
      <string>open</string>
      <string>-a</string>
      <string>Terminal</string>
      <string>${HOME}/Downloads/rebuild_spotlight_index.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
  </dict>
</plist>
EOF
  fi

  # TODO: Add a reboot required flag.
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

configure_control_center() {
  # Check "Show Bluetooth in menu bar"
  defaults -currentHost write com.apple.controlcenter Bluetooth -int 18
  # Check "Show Sound in menu bar: Always"
  defaults -currentHost write com.apple.controlcenter Sound -int 18
  # Check "Show Wi-Fi status in menu bar"
  defaults -currentHost write com.apple.controlcenter WiFi -int 18
  # Check "Show battery status in menu bar"
  defaults -currentHost write com.apple.controlcenter Battery -int 18
  # Uncheck "Show in Menu Bar"
  defaults -currentHost write com.apple.spotlight MenuItemHidden -bool true
  # Uncheck "Show fast user switching menu"
  defaults -currentHost write com.apple.controlcenter UserSwitcher -int 24
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
    open -a Firefox
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

  # Manually configure Firefox.
  # TODO: Automate this process.
  printf '%s\n' "Configure Firefox."
  open -a Firefox
  read -r
}

clone_dotfiles_repository() {
  ssh_key_filename="${SSH_KEY_FILENAME}"
	source_directory="${SOURCE_DIRECTORY}"
	dotfiles_repository="${DOTFILES_REPOSITORY}"

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
  open -a Firefox 'https://github.com/login'
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
  cat << 'EOF' | sudo tee /etc/zshenv > /dev/null
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

  # Manually symlink the ZSH configuration.
  # TODO: Automate this process.
  printf '%s\n' "Symlink the ZSH configuration to the dotfiles directory."
  read -r

  # Cleanup ZSH files left over from fresh install.
  rm -f "${HOME}/.zsh_history"
  rm -rf "${HOME}/.zsh_sessions"
}

# Cleanup Items

import_terminal_profile() {
  # Manually import the Terminal profile.
  # TODO: Automate this process.
  printf '%s\n' "Import a profile into the Terminal application."
  read -r
}

configure_vim() {
  # Create the cache and data directories.
  mkdir -p "${XDG_CACHE_HOME:-${HOME}/.cache}/vim"
  mkdir -p "${XDG_DATA_HOME:-${HOME}/.local/share}/vim"

  # Manually symlink the Vim configuration.
  # TODO: Automate this process.
  printf '%s\n' "Symlink the Vim configuration to the dotfiles directory."
  read -r

  # Cleanup Vim files left over from fresh install.
  rm -f "${HOME}/.viminfo"
}

configure_git() {
  # Manually symlink the Git configuration.
  # TODO: Automate this process.
  printf '%s\n' "Symlink the Git configuration to the dotfiles directory."
  read -r

  # Manually create a config-personal file with email and signing key.
  # TODO: Automate this process.
  printf '%s\n' "Create a config-personal file with email and signing key."
  read -r
}

configure_gnupg() {
  # Manually symlink the GnuPG configuration.
  # TODO: Automate this process.
  printf '%s\n' "Symlink the GnuPG configuration to the dotfiles directory."
  read -r
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

  # Manually configure Rectangle.
  # TODO: Automate this process.
  printf '%s\n' "Configure the Rectangle app."
  open -a Rectangle
  read -r
}

setup_signal() {
  # Install Signal with Homebrew (Cask)
  if [ ! -d /Applications/Signal.app ]; then
    brew install --cask signal
  fi

  # Manually configure Signal.
  # TODO: Automate this process.
  printf '%s\n' "Configure Signal."
  open -a Signal
  read -r
}

setup_slack() {
  # Install Slack with Homebrew (Cask)
  if [ ! -d /Applications/Slack.app ]; then
    brew install --cask slack
  fi

  # Manually configure Slack.
  # TODO: Automate this process.
  printf '%s\n' "Configure Slack."
  open -a Slack
  read -r
}

setup_microsoft_teams() {
  # Install Microsoft Teams with Homebrew (Cask)
  if [ ! -d "/Applications/Microsoft Teams.app" ]; then
    brew install --cask microsoft-teams
  fi

  # Manually configure Microsoft Teams.
  # TODO: Automate this process.
  printf '%s\n' "Configure Microsoft Teams."
  open -a "Microsoft Teams"
  read -r
}

setup_zoom() {
  # Install Zoom with Homebrew (Cask)
  if [ ! -d "/Applications/zoom.us.app" ]; then
    brew install --cask zoom
  fi

  # Manually configure Zoom.
  # TODO: Automate this process.
  printf '%s\n' "Configure Zoom."
  open -a zoom.us
  read -r
}

main() {
  # Turn on Debugging Output
  export PS4=" -> + "
  set -o xtrace

  # Globally enable exit-on-error and require variables to be set.
  set -o errexit
  set -o nounset

  # Ask for the administrator password upfront.
  sudo -v

  # Keep-alive: update existing `sudo` time stamp until script has finished.
  while true; do 
    sudo -n true; sleep 60; kill -0 "$$" || exit; 
  done 2>/dev/null &

  configuration
  capitalize_username
  setup_xdg_directories
  add_source_directory
  install_homebrew
  configure_ssh
  setup_gnupg
  setup_pass

  login_apple_id
  login_exchange

# Security and Privacy settings require sudo.
  configure_security_and_privacy
# Security and Privacy settings require sudo.
  configure_software_update
  configure_control_center
# Keyboard requires Logout/Login for all settings to take affect.
  configure_keyboard
#  configure_displays
  configure_battery

  configure_finder
  configure_safari
  configure_textedit
#  configure_mail
#  configure_calendar

  setup_firefox
  clone_dotfiles_repository
  configure_zsh

  import_terminal_profile
  configure_vim
  configure_git
  configure_gnupg
  configure_less

  setup_rectangle
  setup_signal
  setup_slack
  setup_microsoft_teams
#  setup_zoom

# Dock requires some applications to be installed first.
  configure_dock_and_menu_bar
# Spotlight requires a reboot.
  configure_spotlight

  # Reboot to rebuild the Spotlight Index.
  #sudo reboot
  printf '%s\n' "Reboot the machine now."
  read -r
}

main "$@"

#!/bin/sh
#
# setup.sh - macOS installation shell script.

# Prepare the OS

capitalize_username() {
	:  # This can't be automated as far as I can tell.
}

cleanup_dock() {
	:  # Configure which applications are in the Dock in a declarative way.
	:  # Configure the size of the Dock in a declarative way.
}

add_source_directory() {
	:  # Check if the directory exists.
	:  # Create it.
	:  # Use a custom icon.
}

install_homebrew() {
	# Homebrew (taken from their website)
	# https://developer.apple.com/download/more/
	#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	:
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
	:  #
}

configure_spotlight() {
	:  #
}

configure_passwords() {
	:  # Disable "Detect compromised passwords".
}

configure_security_and_privacy() {
	:  #
}

configure_software_update() {
	:  # Enable automatic updates.
}

configure_bluetooth() {
	:  #
}

configure_sound() {
	:  #
}

configure_keyboard() {
	:  #
}

configure_displays() {
	:  #
}

# Application Preferences

configure_finder() {
	:  #
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

# Command Line Utilities

configure_ssh() {
	:  # Generate an SSH keypair.
	:  # Copy the public SSH key to my server.
}

setup_gnupg() {
	:  # Check if SSH is configured.
	:  # Install gnupg with Homebrew.
	:  # Copy the GPG keys from my server.
	:  # Import the GPG keys.
	:  # Set the trust level on the GPG keys.
}

setup_pass() {
	:  # Check if GnuPG and SSH are setup and configured.
	:  # Install pass with Homebrew.
	:  # Clone the Password Store Git repository.
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

	capitalize_username
	cleanup_dock
	add_source_directory
	install_homebrew
	login_apple_id
	login_exchange

	configure_dock_and_menu_bar
	configure_spotlight
	configure_passwords
	configure_security_and_privacy
	configure_software_update
	configure_bluetooth
	configure_sound
	configure_keyboard
	configure_displays

	configure_finder
	configure_safari
	configure_textedit
	configure_mail
	configure_calendar

	configure_ssh
	setup_gnupg
	setup_pass
	setup_firefox
	clone_dotfiles_repository
	configure_zsh

	import_terminal_profile
	configure_vim
	configure_git
	configure_gnupg
	configure_less

	setup_rectangle
}

main "$@"


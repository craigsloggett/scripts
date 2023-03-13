#!/bin/sh
#
# setup.sh - macOS installation shell script.

configuration() {
  # Setup configuration variables.
  export SOURCE_DIRECTORY="${SOURCE_DIRECTORY:-${HOME}/Source}"
  export SSH_KEY_FILENAME="${SSH_KEY_FILENAME:-id_ed25519}"
  export GPG_PUBLIC_KEY="${GPG_PUBLIC_KEY:-23BF43EF}"
  export GPG_KEY_FILENAME="${GPG_KEY_FILENAME:-secret-subkeys.gpg}"
  export DOTFILES_REPO="${DOTFILES_REPO:-github.com:nerditup/dotfiles.git}"

  # Output the configuration.
  printf '%s\n' "SOURCE_DIRECTORY=${SOURCE_DIRECTORY}"
  printf '%s\n' "SSH_KEY_FILENAME=${SSH_KEY_FILENAME}"
  printf '%s\n' "GPG_PUBLIC_KEY=${GPG_PUBLIC_KEY}"
  printf '%s\n' "GPG_KEY_FILENAME=${GPG_KEY_FILENAME}"
  printf '%s\n' "DOTFILES_REPO=${DOTFILES_REPO}"
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

main() {
  # Turn on Debugging Output
#  export PS4=" -> + "
#  set -o xtrace

  # Globally enable exit-on-error and require variables to be set.
  set -o errexit
  set -o nounset

  readonly c1='\033[1;33m'  # Yellow
  readonly c2='\033[1;34m'  # Blue
  readonly rc='\033[m'      # Reset

  log "Begin macOS configuration."

  # Ask for the administrator password upfront.
  log 'Root privileges are required for most of the configuration.'
  log 'sudo: Asking for the user password...'
  sudo -v

  # Keep-alive: Update existing `sudo` time stamp until script has finished.
  while true; do
    sudo -n true; sleep 60; kill -0 "$$" || exit;
  done 2>/dev/null &

  log 'Found the following configuration in the current environment:'
  configuration

#  setup_pass
}

main "$@"

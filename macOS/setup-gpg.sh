#!/bin/sh
#
# setup-gpg.sh - macOS installation shell script.

configuration() {
  # Setup configuration variables.
  export GPG_PUBLIC_KEY="${GPG_PUBLIC_KEY:-23BF43EF}"
  export GPG_KEY_FILENAME="${GPG_KEY_FILENAME:-secret-subkeys.gpg}"

  # Output the configuration.
  printf '%s\n' "GPG_PUBLIC_KEY=${GPG_PUBLIC_KEY}"
  printf '%s\n' "GPG_KEY_FILENAME=${GPG_KEY_FILENAME}"
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

  log 'Configuring GnuPG...'
#  setup_gnupg
}

main "$@"

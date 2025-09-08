#!/bin/sh
#
# bootstrap.sh - macOS installation shell script.
#
# This script can be configured via the use of environment variables.
#
# +------------------+---------------------------------------------+
# |         Variable | Description                                 |
# +------------------+---------------------------------------------+
# |                  |                                             |
# |      SOURCE_PATH | The path to the source directory.           |
# |                  |                                             |
# | SCRIPTS_REPO_URL | Repository hosting the installation script. |
# |                  |                                             |
# | INSTALL_HOMEBREW | Install the Homebrew package manager.       |
# |                  |                                             |
# +------------------+---------------------------------------------+

get_repo_name() {
  # Get the basename of the repository URL.
  repo_name="${SCRIPTS_REPO_URL##*/}"
  repo_name="${repo_name%%.*}"

  printf '%s\n' "$repo_name"
}

get_repo_user() {
  # Get the GitHub user from the repository URL.
  repo_user="${1#*github.com/}"; 
  repo_user="${repo_user%%/*}"; 

  printf '%s\n' "$repo_user"
}

get_latest_repo() (
  repo_name="$(get_repo_name "$1")"
  repo_user="$(get_repo_user "$1")"

  mkdir -p "$SOURCE_PATH/$repo_user"
  cd "$SOURCE_PATH/$repo_user"

  if [ -d "$repo_name" ]; then
    cd "$repo_name"
    git pull
  else
    if [ -n "${2:-}" ]; then
      git clone -b "$2" "$1"
    else
      git clone "$1"
    fi
  fi
)

install_homebrew() {
  printf '%s\n' "Asking for sudo password in order to install Homebrew."

  # Homebrew (taken from their website)
  # https://developer.apple.com/download/more/
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
}

main() {
  # Globally enable exit-on-error and require variables to be set.
  set -o errexit
  set -o nounset

  # Allow the user to not install the Homebrew package manager as part 
  # of the bootstrap process. Homebrew is a requirement.
  [ "$INSTALL_HOMEBREW" = 0 ] || install_homebrew

  get_latest_repo "$SCRIPTS_REPO_URL"

  repo_name="$(get_repo_name "$SCRIPTS_REPO_URL")"
  repo_user="$(get_repo_user "$SCRIPTS_REPO_URL")"

  # Very specific to my dotfiles repository.
  cd "$SOURCE_PATH/$repo_user/$repo_name/macOS"

  ./macsh
}

main "$@"


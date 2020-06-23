#!/usr/bin/env bash
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

die() {
  printf 'ERROR: %s\n' "$1"
  exit 1
}

get_repo_name() {
  # Get the basename of the repository URL.
  repo_name="${SCRIPTS_REPO_URL##*/}"
  repo_name="${repo_name%%.*}"

  printf '%s\n' "$repo_name"
}

get_latest_scripts() {
  mkdir -p "$SOURCE_PATH"

  if [ ! -d "$SOURCE_PATH/$repo_name" ]; then
    git clone "$SCRIPTS_REPO_URL" "$SOURCE_PATH/$repo_name"
  else
    (
      cd "$SOURCE_PATH/$repo_name"
      git pull
    )
  fi
}

install_homebrew() {
  # Homebrew (taken from their website)
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
}

main() {
  # Globally enable exit-on-error and require variables to be set.
  set -o errexit
  set -o nounset

  # Error here if the user has not set SOURCE_PATH.
  [ "$SOURCE_PATH" ] || die "\$SOURCE_PATH needs to be set."

  # Error here if the user has not set SCRIPTS_REPO_URL.
  [ "$SCRIPTS_REPO_URL" ] || die "\$SCRIPTS_REPO_URL needs to be set."

  # Allow the user to not install the Homebrew package manager as part 
  # of the bootstrap process. Homebrew is a requirement.
  [ "$INSTALL_HOMEBREW" = 0 ] || install_homebrew

  repo_name=$(get_repo_name)

  get_latest_scripts

  cd "$SOURCE_PATH/$repo_name/macOS"

  source macsh
}

main "$@"


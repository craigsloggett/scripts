#!/usr/bin/env bash
#
# bootstrap.sh - macOS installation shell script.
#
# This script can be configured via the use of environment variables.
#
# +------------------+-----------------------------------------+
# |         Variable | Description                             |
# +------------------+-----------------------------------------+
# |                  |                                         |
# |      SOURCE_PATH | The path to the source directory.       |
# |                  |                                         |
# |         REPO_URL | Repository for the installation script. |
# |                  |                                         |
# | INSTALL_HOMEBREW | Install the Homebrew package manager.   |
# |                  |                                         |
# +------------------+-----------------------------------------+

log() {
  printf '%s %s\n' "${2:-->}" "$1" >&2
}

die() {
  log "$1" "${2:-ERROR}"
  exit 1
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
  [ "$SOURCE_PATH" ] || die "\$SOURCE_PATH needs to be set"

  # Error here if the user has not set REPO_URL.
  [ "$REPO_URL" ] || die "\$REPO_URL needs to be set"

  # Allow the user to not install the Homebrew package manager as part 
  # of the bootstrap process. Homebrew is a requirement.
  [ "$INSTALL_HOMEBREW" = 0 ] || install_homebrew

  # Get the basename of the repository URL.
  repo_name="${REPO_URL##*/}"
  repo_name="${repo_name%%.*}"

  mkdir -p "$SOURCE_PATH"

  if [[ -d "$SOURCE_PATH/$repo_name" ]]; then
      rm -rf "$SOURCE_PATH/$repo_name"
  fi

  git clone "$REPO_URL" "$SOURCE_PATH/$repo_name"

  cd "$SOURCE_PATH/$repo_name/macOS"

  source macsh
}

main "$@"


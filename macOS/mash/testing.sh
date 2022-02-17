#!/bin/sh
#
# testing.sh - Testing library functionality.

# shellcheck source=/dev/null
. "${XDG_LIB_HOME:-${HOME}/.local/lib}/shell/logging"
. "${XDG_LIB_HOME:-${HOME}/.local/lib}/shell/file"

logging() {
  info testing
  debug testing
  warning testing
  error testing
}

file() {
  file_exists "${0}"
}

logging
file
echo $?

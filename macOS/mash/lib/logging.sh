#!/bin/sh
#
# logging.sh - Standard logging functions.

readonly colour_red='\033[0;31m'
readonly colour_yellow='\033[0;33m'
readonly colour_blue='\033[0;34m'
readonly colour_reset='\033[0m'

info() {
  message="${1}"

  printf ' INFO    | %s\n' \
      "${message}"
}

debug() {
  message="${1}"

  printf '%b DEBUG   | %b%s\n' \
      "${colour_blue}" "${colour_reset}" "${message}"
}

warning() {
  message="${1}"

  printf '%b WARNING | %b%s\n' \
      "${colour_yellow}" "${colour_reset}" "${message}"
}

error() {
  message="${1}"

  printf '%b ERROR   | %b%s\n' \
      "${colour_red}" "${colour_reset}" "${message}" >&2
}

#!/bin/sh
#
#

logging() {
  . lib/logging.sh

  info testing
  debug testing
  warning testing
  error testing
}

logging

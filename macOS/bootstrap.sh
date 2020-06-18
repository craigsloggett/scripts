#!/bin/bash
#
# bootstrap.sh - macOS installation shell script.

main() {
    # homebrew (taken from their website)
    #/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

    # system configuration
    mkdir -p "${HOME}"/Source/GitHub/craigsloggett
    
    if [[ ! -d "${HOME}"/Source/GitHub/craigsloggett/scripts ]]; then
        cd "${HOME}"/Source/GitHub/craigsloggett
        git clone https://github.com/craigsloggett/scripts.git
    fi

    cd "${HOME}"/Source/GitHub/craigsloggett/scripts/macOS

    source macsh
}

main "$@"


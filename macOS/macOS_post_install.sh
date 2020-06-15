#!/bin/bash

_XDG_CONFIG_HOME="${XDG_CONFIG_HOME:=${HOME}/.config}"
_XDG_CACHE_HOME="${XDG_CACHE_HOME:=${HOME}/.cache}"
_XDG_DATA_HOME="${XDG_DATA_HOME:=${HOME}/.local/share}"

_SECURE_REMOTE_LOCATION="${SECURE_REMOTE_LOCATION}"

# Setup ZSH
sudo install -C -m 644 etc/zshenv /etc/zshenv

# Setup XDG Directories
mkdir -p "${_XDG_CONFIG_HOME}"
mkdir -p "${_XDG_CACHE_HOME}"
mkdir -p "${_XDG_DATA_HOME}"

# SSH
mkdir -p "${HOME}"/.ssh
scp "${SECURITY_USER}"@"${SECURITY_HOST}":"${SECURITY_DIR}"/ssh/"${COMPANY_NAME}"/id_ed25519 "${HOME}"/.ssh
scp "${SECURITY_USER}"@"${SECURITY_HOST}":"${SECURITY_DIR}"/ssh/"${COMPANY_NAME}"/id_ed25519.pub "${HOME}"/.ssh

# Export the values in /etc/zshenv

# Setup GPG

# Setup Pash

# Setup Firefox

#637387

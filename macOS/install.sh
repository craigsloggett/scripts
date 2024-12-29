#!/bin/sh

SSH_KEYFILE="${HOME}/.ssh/id_ed25519"

mkdir -p ~/Developer

if [ ! -f "${SSH_KEYFILE}" ]; then
  ssh-keygen -q -t ed25519 -f "${SSH_KEYFILE}" -N ''
fi

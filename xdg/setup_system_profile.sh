#!/bin/sh
#
# Add the XDG Base Directory Specification environment variables to the system profile.

readonly TARGET_FILE="/etc/profile.d/xdg-base-directory-specification.sh"

touch "${TARGET_FILE}"
chmod 644 "${TARGET_FILE}"
chown root:root "${TARGET_FILE}"

cat <<- 'EOF' > "${TARGET_FILE}"
	# XDG Base Directory Specification environment variables.

	# User	
	export XDG_CONFIG_HOME="${HOME}/.config"
	export XDG_CACHE_HOME="${HOME}/.cache"
	export XDG_DATA_HOME="${HOME}/.local/share"
	
	# System
	export XDG_DATA_DIRS="/usr/local/share:/usr/share"
	export XDG_CONFIG_DIRS="/etc/xdg"
EOF

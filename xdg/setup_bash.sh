#!/bin/sh
#
# Force BASH to use the XDG Base Directory Specification environment variables.

readonly TARGET_FILE="/etc/profile.d/xdg-bash.sh"

touch "${TARGET_FILE}"
chmod 644 "${TARGET_FILE}"
chown root:root "${TARGET_FILE}"

cat <<- 'EOF' > "${TARGET_FILE}"
	# BASH XDG Specification
	
	if [ -n "$BASH_VERSION" ]; then
		. "${XDG_CONFIG_HOME}"/bash/profile
		. "${XDG_CONFIG_HOME}"/bash/bashrc
		export HISTFILE="${XDG_DATA_HOME}"/bash/history
	fi
EOF

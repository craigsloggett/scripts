# BASH Completion XDG Specification

if [ -n "$BASH_VERSION" ]; then
	export BASH_COMPLETION_USER_FILE="${XDG_CONFIG_HOME}"/bash-completion/bash_completion
fi

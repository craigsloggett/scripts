# BASH XDG Specification

if [ -n "$BASH_VERSION" ]; then
	. "${XDG_CONFIG_HOME}"/bash/profile
	. "${XDG_CONFIG_HOME}"/bash/bashrc
	export HISTFILE="${XDG_DATA_HOME}"/bash/history
fi


# Handle the style control for the completion system
zstyle :compinstall filename "${XDG_CONFIG_HOME}/zsh/zshrc"
# Handle git auto completion (requires the git-completion.zsh script from git source)
zstyle ':completion:*:*:git:*' script "${XDG_CONFIG_HOME}/zsh/git-completion.zsh"

# Enable autocompletion
autoload -Uz compinit 
compinit -d "${XDG_CACHE_HOME}/zsh/zcompdump-${ZSH_VERSION}"

# Terminal history settings
HISTFILE="${XDG_DATA_HOME}"/zsh/history
HISTSIZE=5000
SAVEHIST=5000

# Set the Zsh Line Editor mode to vi
#bindkey -v

# Load the prompt theme system
autoload -Uz promptinit
promptinit

# Configure the Left Prompt
PROMPT=' %(!.%F{red}%B.%F{green}%B)%n@%m %*%b%f %~ %(!.#.$) '

# Load the git prompt script to show on the right prompt
setopt prompt_subst
. "${XDG_CONFIG_HOME}"/zsh/git-prompt.sh

# Configure the git details to display
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="auto"
GIT_PS1_SHOWCOLORHINTS=1

# Configure the Right Prompt
export RPROMPT=$'$(__git_ps1 "%s")'

# Aliases
. "${XDG_CONFIG_HOME}/zsh/zsh_aliases"

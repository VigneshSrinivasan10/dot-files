# Add local bin to path
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Editor settings
export EDITOR="vim"
export VISUAL="vim"

# Better man pages
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt EXTENDED_HISTORY

# Navigation shortcuts
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias -- -="cd -"

# File operations (with safety)
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"
alias mkdir="mkdir -pv"

# Quick config edits
alias zshrc="vim ~/.zshrc"
alias vimrc="vim ~/.vimrc"
alias reload="source ~/.zshrc && echo 'Zsh config reloaded!'"

# System info
alias df="df -Th"
alias du="du -h"
alias free="free -h"
alias ps="ps auxf"
alias btop="htop"

# Search and find
alias grep="rg"  # Use ripgrep instead
alias find="fd"  # Use fd instead
alias f="fd --type f --hidden --exclude .git | fzf"  # Find files with fzf
alias d="fd --type d --hidden --exclude .git | fzf"  # Find directories with fzf

# Python
alias py="python3"
alias py2="python2"
alias pip="pip3"

# Network
alias ports="sudo lsof -i -P -n | grep LISTEN"
alias myip="curl -s ifconfig.me"
alias localip="ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print \$2}' | cut -d/ -f1"
alias ping="ping -c 5"
alias traceroute="tracepath"

# Archives
alias tarx="tar -xvf"
alias tarc="tar -cvf"
alias tarz="tar -czvf"
alias tarj="tar -cjvf"
alias untar="tar -xvf"

# Clipboard (cross-platform)
alias copy="xclip -selection clipboard"
alias paste="xclip -selection clipboard -o"
alias cpc="xclip -selection clipboard"
alias cpv="xclip -selection clipboard -o"

# History
alias h="history"
alias hg="history | grep"
alias hcl="history | awk '{print \$2}' | sort | uniq -c | sort -rn | head"

# Safety nets
alias chmod="chmod --preserve-root"
alias chown="chown --preserve-root"

# Auto-start tmux
if [ -z "$TMUX" ] && [ -n "$SSH_CONNECTION" ]; then
  tmux attach-session -t ssh || tmux new-session -s ssh
fi

alias tm="tmux"
alias tma="tmux attach -t"
alias tml="tmux list-sessions"
alias tmk="tmux kill-session"
alias tmn="tmux new-session -s"

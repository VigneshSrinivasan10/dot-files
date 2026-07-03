# ~/.zshenv — sourced by EVERY zsh (interactive, login, and non-interactive
# script shells alike). This is the only rc file guaranteed to run for
# non-interactive tools (e.g. Claude Code's Bash calls), so the ssh-agent
# setup lives here rather than in .zshrc.

# Persistent per-node ssh-agent (shared with bash — see the script for why
# the socket must be on node-local /tmp, not NFS $HOME).
source "$HOME/dot-files/shell/ssh-agent.sh"

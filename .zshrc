# ============================================
# POWERLEVEL10K INSTANT PROMPT (must be first)
# ============================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSH_CONFIG_DIR="$HOME/.config/zsh"

source "$ZSH_CONFIG_DIR/oh-my-zsh.zsh"
source "$ZSH_CONFIG_DIR/env.zsh"
source "$ZSH_CONFIG_DIR/tools.zsh"
source "$ZSH_CONFIG_DIR/aliases/core.zsh"
source "$ZSH_CONFIG_DIR/aliases/git.zsh"
[[ -f "$ZSH_CONFIG_DIR/aliases/projects.zsh" ]] && source "$ZSH_CONFIG_DIR/aliases/projects.zsh"
source "$ZSH_CONFIG_DIR/functions.zsh"
source "$ZSH_CONFIG_DIR/tmux.zsh"
source "$ZSH_CONFIG_DIR/slurm.zsh"
source "$ZSH_CONFIG_DIR/keybindings.zsh"

# ============================================
# LOAD POWERLEVEL10K CONFIG
# ============================================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH=/home/vsrini/.opencode/bin:$PATH

unset PREFIX
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm alias default v20.20.0 > /dev/null 2>&1

# SSH agent auto-start
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add ~/.ssh/id_rsa 2>/dev/null
fi

. "$HOME/.local/bin/env"

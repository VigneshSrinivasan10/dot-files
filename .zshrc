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
source "$ZSH_CONFIG_DIR/aliases/projects.zsh"
source "$ZSH_CONFIG_DIR/functions.zsh"
source "$ZSH_CONFIG_DIR/tmux.zsh"
source "$ZSH_CONFIG_DIR/slurm.zsh"
source "$ZSH_CONFIG_DIR/keybindings.zsh"

# ============================================
# LOAD POWERLEVEL10K CONFIG
# ============================================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
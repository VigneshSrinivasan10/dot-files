# ---- Zoxide (smarter cd) ----
eval "$(zoxide init zsh)"
alias cd="z"  # Replace cd with zoxide
alias zz="z -"  # Go to previous directory

# ---- FZF (fuzzy finder) ----
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# FZF with previews using eza and bat
show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview' --preview-window right:60%:wrap"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info --preview-window wrap"

# Custom fzf completion
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'" "$@" ;;
    ssh)          fzf --preview 'dig {}' "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# ---- Eza (modern ls) ----
alias ls="eza --icons --group-directories-first"
alias ll="eza -l --icons --group-directories-first --git"
alias la="eza -a --icons --group-directories-first"
alias lt="eza --tree --icons --level=2"
alias lta="eza --tree --icons --level=2 -a"
alias l="eza -lah --icons --group-directories-first --git"
alias lg="eza -lah --icons --git --git-ignore"

# ---- Bat (modern cat) ----
alias cat="bat --paging=never"
alias catp="bat --plain"
alias less="bat"
export BAT_THEME="Dracula"
export BAT_STYLE="numbers,changes,header"

# ---- Delta (better git diff) ----
export GIT_PAGER="delta"
export DELTA_FEATURES="side-by-side line-numbers decorations"
export DELTA_NAVIGATE="true"

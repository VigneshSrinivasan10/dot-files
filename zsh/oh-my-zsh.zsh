export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Performance optimizations
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_AUTO_TITLE="true"
ENABLE_CORRECTION="false"
COMPLETION_WAITING_DOTS="true"

# Plugins - load order matters!
plugins=(
  git
  sudo
  history
  colored-man-pages
  colorize
  command-not-found
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  fzf
  zsh-z
  docker
  docker-compose
  npm
  node
  python
  pip
  terraform
  kubectl
  helm
)

source "$ZSH/oh-my-zsh.sh"

# Vim mode
bindkey -v
export KEYTIMEOUT=1

# Better navigation
bindkey '^[[A' up-line-or-search    # Up arrow
bindkey '^[[B' down-line-or-search  # Down arrow
bindkey '^[[H' beginning-of-line    # Home
bindkey '^[[F' end-of-line          # End
bindkey '^[[3~' delete-char         # Delete
bindkey '^R' fzf-history-widget     # Ctrl+R for fzf history

# Autosuggestions
bindkey '^ ' autosuggest-accept      # Ctrl+Space to accept suggestion
bindkey '^f' autosuggest-accept      # Ctrl+F to accept suggestion

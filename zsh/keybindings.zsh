# Vim mode
bindkey -v
export KEYTIMEOUT=1

# Bracketed paste — protects against vi-mode interpreting paste-end ESC[201~
# (which would toggle the case of the last pasted character via vi `~`)
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

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

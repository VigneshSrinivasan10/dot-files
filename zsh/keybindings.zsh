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

# Swallow stray terminal query replies. On tmux attach (and TUI redraws) the
# outer terminal answers queries — background color (^[]11;rgb:...^[\) and
# device attributes (^[[?61;...c, ^[[>0;10;1c). Over ssh those replies can
# arrive after the querier stopped listening, get treated as keystrokes, and
# echo as junk at the prompt. No real key starts with these prefixes, so bind
# them to widgets that read to the end of the reply and discard it.
_eat-osc-reply() {  # ESC ] ... terminated by BEL or ST (ESC \)
  local c
  while read -t 0.1 -k 1 c; do
    [[ $c == $'\a' || $c == '\\' ]] && break
  done
}
_eat-csi-reply() {  # ESC [ ? / ESC [ > ... terminated by a final letter
  local c
  while read -t 0.1 -k 1 c; do
    [[ $c == [a-zA-Z] ]] && break
  done
}
zle -N _eat-osc-reply
zle -N _eat-csi-reply
for _m in viins vicmd; do
  bindkey -M $_m '\e]'  _eat-osc-reply
  bindkey -M $_m '\e[>' _eat-csi-reply
  bindkey -M $_m '\e[?' _eat-csi-reply
done
unset _m

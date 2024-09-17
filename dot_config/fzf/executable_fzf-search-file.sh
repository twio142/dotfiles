#!/bin/zsh

## Search files with fzf, sort by modification time

FD_PREFIX="fd -H -L --type f --exclude '.DS_Store' --exclude '.git' "
FD_SUFFIX=". --exec-batch stat -f '%m %N' \; | sort -rn | choose 1.."
INITIAL_QUERY="${*:-}"
fzf --ansi --disabled --query "$INITIAL_QUERY" -m \
    --color "hl:-1:underline,hl+:-1:underline:reverse" \
    --bind "start:reload:$FD_PREFIX {q} $FD_SUFFIX" \
    --bind "change:reload:$FD_PREFIX {q} $FD_SUFFIX || true" \
    --preview 'bat --color=always {}' \
    --bind "ctrl-f:reload(cat $XDG_CACHE_HOME/neomru/file | sed '2,21!d')+change-header( Recent files )"

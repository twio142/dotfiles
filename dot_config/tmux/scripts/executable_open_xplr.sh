#!/bin/zsh

export PATH="$HOME/bin:$PATH"
export FZF_DEFAULT_OPTS='--layout=reverse --cycle --inline-info --color=fg+:-1,bg+:-1,hl:bright-red,hl+:red,pointer:bright-red,info:-1,prompt:-1 --pointer=➤ --bind="ctrl-d:preview-page-down" --bind="ctrl-u:preview-page-up"'

[ -f $(brew --prefix)/etc/profile.d/autojump.sh ] && . $(brew --prefix)/etc/profile.d/autojump.sh
autoload -U compinit && compinit -u

xplr

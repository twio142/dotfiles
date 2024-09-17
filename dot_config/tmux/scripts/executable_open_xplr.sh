#!/bin/zsh

export PATH="$HOME/.local/bin:$PATH"
export EDITOR=nvim
export LESS="-R"
export LESSHISTFILE=$XDG_STATE_HOME/less/history
export PAGER="bat --style=plain --color=always --paging=always --pager=less"
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind='ctrl-d:preview-half-page-down' --bind='ctrl-u:preview-half-page-up'"

xplr

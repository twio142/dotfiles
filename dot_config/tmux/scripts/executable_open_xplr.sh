#!/bin/zsh

export PATH="$HOME/bin:$PATH"
export EDITOR=nvim
export LESS="-R"
export PAGER="bat --style=plain --color=always --paging=always --pager=less"
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind='ctrl-d:preview-down' --bind='ctrl-u:preview-up'"

source $(brew --prefix)/share/autojump/autojump.zsh

xplr

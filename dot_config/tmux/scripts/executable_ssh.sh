#!/bin/zsh

if [ -z "$1" ]; then
  tmux display "hostname required"
  exit 1
fi
tmux rename-window "$1"
TERM=screen-256color ssh "$@"

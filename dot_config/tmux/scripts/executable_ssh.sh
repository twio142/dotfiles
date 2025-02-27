#!/bin/zsh

# ssh into a remote host in a new tmux window
# if multiple hosts are provided, split the window

if [ -z "$1" ]; then
  tmux display "hostname required"
  exit 1
fi
if [[ "$#" -gt 1 && "$1" != - ]]; then
  _first=$1
  shift
  for i in "$@"; do
    tmux splitw -v "ssh $i"
  done
  tmux selectl -E
  ssh "$_first"
else
  [ "$1" = - ] && shift
  tmux renamew "$1"
  ssh "$@"
fi

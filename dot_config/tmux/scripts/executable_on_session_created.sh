#!/bin/zsh

if [ -n "$SSH_CONNECTION" ]; then
  tmux set prefix2 "C-b"
  tmux bind -n "C-b" send-prefix -2
  tmux set @ssh_connection "yes"
  tmux set -g clipboard on
  tmux has -t ssh 2> /dev/null || tmux rename ssh
fi

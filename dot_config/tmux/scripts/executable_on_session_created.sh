#!/bin/zsh

if [ -n "$SSH_CONNECTION" ]; then
  tmux set prefix2 "C-b"
  tmux bind "C-b" send-prefix -2
  tmux set @ssh_connection "yes"
  tmux has-session -t ssh 2> /dev/null || tmux rename-session ssh
fi

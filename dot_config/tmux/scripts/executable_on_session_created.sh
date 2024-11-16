#!/bin/zsh

tmux source $XDG_CONFIG_HOME/tmux/lazy.tmux

if [ -n "$SSH_CONNECTION" ]; then
  tmux set prefix2 "C-b"
  tmux bind -n "C-b" send-prefix -2
  tmux set @ssh_connection "yes"
  tmux set -g clipboard on
  tmux has -t ssh 2> /dev/null || tmux rename ssh
else
  sess=$(tmux display-message -p '#S')
  if [[ "$sess" =~ '^[0-9]+$' && "$sess" -gt 0 ]]; then
    for i in $(seq 1 $sess); do
      tmux has -t $i 2> /dev/null || { tmux rename $i; break; }
    done
  fi
fi

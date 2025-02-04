#!/bin/zsh

tmux source $XDG_CONFIG_HOME/tmux/lazy.tmux

if [ -n "$SSH_CONNECTION" ]; then
  tmux set prefix2 "C-b"
  tmux bind -n "C-b" send-prefix -2
  tmux set @ssh_connection "yes"
  tmux set -g clipboard on
  tmux has -t ssh 2> /dev/null || tmux rename ssh
else
  sess=$(tmux display -p '#S')
  if [[ "$sess" =~ '^[0-9]+$' && "$sess" -gt 0 ]]; then
    for i in $(seq 0 $sess); do
      tmux has -t $i 2> /dev/null || { tmux rename $i; break; }
    done
  fi
fi

client=$(tmux display -p '#{client_pid}')
client=$(ps -o ppid= -p $client)
client=$(ps -o ppid= -p $client)
ps -p $client -o comm= | grep -q 'Visual Studio Code' && tmux set escape-time 10 || true

#!/bin/zsh

tmux source $XDG_CONFIG_HOME/tmux/lazy.tmux

if [ -n "$SSH_CONNECTION" ]; then
  # ssh session
  tmux set prefix2 "C-b"
  tmux bind -n "C-b" send-prefix -2
  tmux set @ssh_connection "yes"
  tmux set -g clipboard on
  tmux has -t ssh 2> /dev/null || tmux rename ssh
else
  client=$(ps -o ppid= -p $(ps -o ppid= -p $(tmux display -p '#{client_pid}')))
  # vscode session
  if (ps -p $client -o comm= | grep -q 'Visual Studio Code'); then
    dir=$(tmux display -p '#{session_path}')
    if (tmux has -t code/${dir:t} 2> /dev/null); then
      if [ $(tmux display -t code/${dir:t} -p '#{session_attached}') = 0 ]; then
        tmp=$(tmux display -p '#S')
        tmux attach -t code/${dir:t}
        tmux kill-session -t $tmp
      fi
    else
      tmux rename code/${dir:t}
    fi
  fi
fi


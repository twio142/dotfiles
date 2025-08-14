#!/bin/zsh

tmux source $XDG_CONFIG_HOME/tmux/lazy.tmux &

if [ -n "$SSH_CONNECTION" ]; then
  # ssh session
  tmux set prefix2 "C-b"
  tmux set @ssh_connection "yes"
  tmux set -s set-clipboard on
  tmux has -t ssh 2> /dev/null || tmux rename ssh
else
  tmux set -s set-clipboard off
  sess=$(tmux display -p '#S')
  if test "$sess" -gt 0 2>/dev/null ; then
    # numbered session
    names=$(tmux list-sessions -F '#S')
    for i in $(seq 0 $(($sess-1))); do
      if ! echo $names | grep -Fxq $i; then
        tmux rename $i
        break
      fi
    done
  fi
fi

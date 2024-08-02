#!/bin/bash

# if opened in nvim, open file in nvim
# if opened in tmux, open file in current pane

if [ -n "$NVIM" ]; then
  nvim --server "$NVIM" --remote-send q && nvim --server "$NVIM" --remote-tab "$@"
  exit 0
elif [ -n "$TMUX" ]; then
  line=$(tmux display -p -F "#{pane_pid}	#{pane_current_command}")
  IFS=$'\t' read -r pid cmd <<< "$line"
  if [ "$cmd" = nvim ]; then
    until (ps -o command= -p $pid | grep -Eq "^nvim --embed"); do
      pid=$(pgrep -P $pid 2> /dev/null)
      [ -z "$pid" ] && break
    done
    socket=$(find $TMPDIR -type s -path "*nvim.$pid.*" 2> /dev/null)
    [ -z "$socket" ] || {
      nvim --server "$socket" --remote-tab "$@";
      tmux popup -C
      exit 0
    }
  fi
fi
nvim -- "$@"

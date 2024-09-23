#!/bin/zsh

case $1 in
  h) flag=L; pos=left;;
  j) flag=D; pos=bottom;;
  k) flag=U; pos=top;;
  l) flag=R; pos=right;;
  *) exit 1 ;;
esac

IFS=' ' read -r cmd _end <<< $(tmux display-message -p "#{pane_current_command} #{pane_at_${pos}}#{window_zoomed_flag}")
[[ "$cmd" == nvim || "$_end" -gt 0 ]] &&
  tmux send-keys C-$1 ||
  tmux select-pane -${flag}

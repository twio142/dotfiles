#!/bin/zsh

# Open a popup terminal in tmux, or detach if already in one

SESS=$(tmux display -p '#S')
if [ "$SESS" = 󰨦 ]; then
  tmux detach-client -s 󰨦
else
  tmux popup -E -w 80% -h 60% -d '#{pane_current_path}' "tmux new -A -s 󰨦 -e TMUX_POPUP=1 -e NON_FIRST_SHELL=1 -e TMUX_ORIGIN=$SESS \\; set status off"
fi

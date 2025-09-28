#!/bin/zsh

# Open a popup terminal in tmux, or detach if already in one

SESS=$(tmux display -p '#S')
if [ "$SESS" = popup ]; then
  tmux detach-client -s popup
else
  tmux popup -E -w 95% -h 90% -d '#{pane_current_path}' "tmux new -A -s popup -e TMUX_POPUP=1 -e NON_FIRST_SHELL=1 -e TMUX_ORIGIN=$SESS 'zsh -l' \\; set status off"
fi

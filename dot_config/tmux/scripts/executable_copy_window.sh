#!/bin/zsh

# copy the current pane in a new window

cwd=$(tmux display-message -p "#{pane_current_path}")
start=$(tmux show-option -gqv default-command)

tmpfile=$(mktemp)
tmux send-keys "export -p > $tmpfile" C-m
sleep 0.5
tmux new-window -c $cwd "source $tmpfile; $start"
sleep 0.5
rm "$tmpfile"

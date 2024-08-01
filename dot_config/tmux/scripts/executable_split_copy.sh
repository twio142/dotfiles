#!/bin/zsh

# copy the current pane in a split pane below and synchronize the input

orig=$(tmux display-message -p "#P")
cwd=$(tmux display-message -p "#{pane_current_path}")
start=$(tmux show-option -gqv default-command)

tmpfile=$(mktemp)
tmux send-keys "export -p > $tmpfile" C-m
sleep 0.5
tmux splitw -v -c $cwd "source $tmpfile; $start"
tmux setw synchronize-panes on
tmux copy-mode -t 1
tmux select-pane -t 2
rm "$tmpfile"


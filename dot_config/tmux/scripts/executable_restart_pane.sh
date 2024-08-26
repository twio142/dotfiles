#!/bin/zsh

# copy the current pane in a new window

start=$(tmux show-option -gqv default-command)

tmpfile=$(mktemp)
tmux send-keys "export -p > $tmpfile" C-m
sleep 0.5

tmux respawnp -k -c "#{pane_current_path}" "source $tmpfile; $start"
sleep 0.5
rm "$tmpfile"

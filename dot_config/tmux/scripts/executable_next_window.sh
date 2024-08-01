#!/bin/bash

# Get the current session ID
session_id=$(tmux display-message -p '#{session_id}')

# Get the count of windows in the current session
window_count=$(tmux list-windows -t $session_id | wc -l)

# If there's only one window, create a new one
if [ "$window_count" -eq 1 ]; then
  tmux new-window -c "~/"
else
  # Switch to the next window
  tmux next-window
fi


#!/bin/zsh

cwd=$(tmux display -p -F "#{pane_current_path}")
git -C "$cwd" rev-parse --is-inside-work-tree 2> /dev/null &&
  tmux popup -E -w 95% -h 90% -d "#{pane_current_path}" "$SHELL -c lazygit" ||
  tmux display "Not in a git repository"

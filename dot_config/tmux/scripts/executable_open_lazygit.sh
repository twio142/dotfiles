#!/bin/zsh

cwd=$(tmux display -p -F "#{pane_current_path}")
if git -C "$cwd" rev-parse --is-inside-work-tree &> /dev/null; then
  tmux popup -E -w 95% -h 90% -x 3% -d "#{pane_current_path}" lazygit
else
  tmux display "Not in a git repository"
fi

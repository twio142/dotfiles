#!/bin/bash

# if opened in nvim, open file in nvim
# if opened in tmux, open file in current pane

if [ -n "$NVIM" ]; then
  nvim --server "$NVIM" --remote-send q && nvim --server "$NVIM" --remote "$@"
  exit 0
elif [ -n "$TMUX" ]; then
  SESS="$(tmux display -p '#S')" $XDG_CONFIG_HOME/tmux/scripts/open_in_vim.sh "$@"
  tmux popup -C
else
  nvim -- "$@"
fi

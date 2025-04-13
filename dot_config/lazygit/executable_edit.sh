#!/bin/bash

# if opened in nvim, open file in nvim
# if opened in tmux, open file in current pane

if [ -n "$NVIM" ]; then
  nvr -cc quit "$@"
  exit 0
elif [ -n "$TMUX_POPUP" ]; then
  ~/.local/bin/tmux-edit "$@"
  tmux popup -C
else
  nvim "$@"
fi

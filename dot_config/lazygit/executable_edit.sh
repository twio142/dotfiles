#!/bin/bash

# if opened in nvim, open file in nvim
# if opened in tmux, open file in current pane

if [ -n "$NVIM" ]; then
  nvr -cc quit "$@"
  exit 0
elif [ -n "$TMUX_POPUP" ]; then
  $XDG_CONFIG_HOME/tmux/scripts/open_in_vim.sh '' "$@"
  tmux popup -C
else
  nvim "$@"
fi

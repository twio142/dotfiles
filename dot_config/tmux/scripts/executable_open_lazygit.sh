#!/bin/zsh

if [ "$1" = --jump ]; then
  cwd=$(awk '/recentrepos:/ {found=1; next} found && /^[^[:space:]]/ {exit} found {print}' $XDG_STATE_HOME/lazygit/state.yml | sd '^ +- ' '' | fzf --preview "echo -e \"\033[1m\$(basename {})\033[0m\n\"; git -c color.status=always -C {} status -bs" --preview-window='wrap' --height=~50%) || exit 0
elif [ -d "$1" ]; then
  cwd=$1
else
  cwd=$PWD
fi

if git -C "$cwd" rev-parse --is-inside-work-tree &> /dev/null; then
else
  cwd=$(awk '/recentrepos:/ {found=1; next} found && /^[^[:space:]]/ {exit} found {print}' $XDG_STATE_HOME/lazygit/state.yml | sd '^ +- ' '' | fzf --preview "echo -e \"\033[1m\$(basename {})\033[0m\n\"; git -c color.status=always -C {} status -bs" --preview-window='wrap' --height=~50%) || exit 0
  # tmux display "Not in a git repository"
fi
lazygit -p "$cwd" &>/dev/null || true

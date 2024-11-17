#!/bin/zsh

_f() {
  awk '/recentrepos:/ {found=1; next} found && /^[^[:space:]]/ {exit} found {print}' $XDG_STATE_HOME/lazygit/state.yml | \
    sd '^ +- ' '' | \
    fzf --preview "echo -e \"\033[1m\$(basename {})\033[0m\n\"; git -c color.status=always -C {} status -bs" \
    --preview-window='up,50%,wrap' \
    --bind "ctrl-o:execute(tmux neww -c {})+abort"
}

if [ -d "$1" ]; then
  cwd=$1
elif [ "$1" = --jump ]; then
  cwd=$(_f) || exit 0
else
  cwd=$PWD
fi

cwd=$(git -C "$cwd" rev-parse --show-toplevel 2> /dev/null) || cwd=$(_f) || exit 0

lazygit -p "$cwd" &>/dev/null || true

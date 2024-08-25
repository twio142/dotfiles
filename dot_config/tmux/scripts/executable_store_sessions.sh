#!/bin/zsh

# store nvim sessions
find $TMPDIR -type s -name 'nvim.*' &> /dev/null | while read -r socket; do
  pid=$(echo ${socket:t:r} | grep -oE '\d+')
  ps -p $pid &> /dev/null || continue
  ~/.local/bin/py3 <<EOF
import pynvim
nvim = pynvim.attach('socket', path='$socket')
nvim.command('Obsess')
EOF
done

# store tmux sessions
~/.config/tmux/plugins/tmux-resurrect/scripts/save.sh

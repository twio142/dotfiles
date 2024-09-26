#!/bin/zsh

# store nvim sessions
find $TMPDIR -type s -name 'nvim.*' &> /dev/null | while read -r socket; do
  pid=$(echo ${socket:t:r} | grep -oE '\d+')
  ps -p $pid &> /dev/null || continue
  ~/.local/bin/python3 <<EOF
import pynvim
nvim = pynvim.attach('socket', path='$socket')
nvim.command('SessionManager save_current_session')
EOF
done

# store tmux sessions
$TMUX_PLUGIN_MANAGER_PATH/tmux-resurrect/scripts/save.sh

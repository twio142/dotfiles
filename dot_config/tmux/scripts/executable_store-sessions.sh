#!/bin/zsh

# store nvim sessions
nvr --serverlist | grep nvim | while read -r server; do
  nvr --servername $server --nostart -c 'SessionManager save_current_session'
done

# store tmux sessions
$TMUX_PLUGIN_MANAGER_PATH/tmux-resurrect/scripts/save.sh

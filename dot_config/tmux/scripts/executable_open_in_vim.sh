#!/bin/zsh

# Open files in nvim in the current pane if it is nvim
# Otherwise open in a new window
# Usage: [NEWW=1] [SESS=...] open_in_vim.sh <client_pid> [-n] <file>...
# NEWW=1|-n: Open in a new window
# SESS: Session name. If given, client_pid is ignored

open_in_existing_pane() {
  pane=$1
  shift
  local win cmd pid
  read win cmd pid <<< $pane
  case $cmd in
    nvim)
      [ "$NEWW" = 1 ] && return
      until (ps -o command= -p $pid | grep -Eq "^nvim --embed"); do
        pid=$(pgrep -P $pid 2> /dev/null)
        [ -z "$pid" ] && break
      done
      local socket=$(fd "(nvim|kickstart)\.$pid.*" $TMPDIR --type s)
      [ -n "$socket" ] && {
        if [[ $# -eq 2 && -f "$1" && "$2" =~ '^[+ ][0-9]+$' ]]; then
          nvim --server $socket --remote "$1" 
          nvim --server $socket --remote-send "${2:1}G"
        elif [ $# -gt 0 ]; then
          nvim --server $socket --remote "$@";
        fi
        exit 0;
      }
      ;;
    zsh)
      local line=$(tmux capture-pane -p -t $win -E - | grep -v '^\s*$' | tail -n1)
      if [[ "$line" = ❯ ]]; then
        cmd="vim"
        for file in $@; do
          file=$(echo $file | sd '^ (\d+)$' '+$1')
          cmd+=" ${file:q}"
        done
        tmux send-keys -t $win "$cmd" Enter
        exit 0
      fi
      ;;
  esac
}

open_in_new_window() {
  local window=$1
  shift
  tmux new-window -t "$window" -c "$HOME"
  local pane=$(tmux display -t "${window%:*}" -p "#P")
  local cmd="vim"
  for file in $@; do
    file=$(echo $file | sd '^ (\d+)$' '+$1')
    cmd+=" ${file:q}"
  done
  tmux send-keys -t $pane "$cmd" Enter
}

getSession() {
  tmux lsc -F '#{client_pid}	#{client_session}' | awk -F '\t' -v pid="$1" '$1 == pid {print $2}'
}

[ -z "$SESS" ] && {
  session=$(getSession $1)
  shift
} || session=$SESS
[ -z "$session" ] && exit 1

if [ "$1" = -n ]; then
  NEWW=1
  shift
fi

tmux list-windows -t "$session" -F "#{window_active}	#{window_index}" | awk -F '\t' '$1 == "1" {print $2}' | while read window; do
  tmux list-panes -t "$session:$window" -F "#{pane_active}	#S:#{window_index}.#P	#{pane_current_command}	#{pane_pid}" | awk -F '\t' '$1 == "1" { $1=""; print $0 }' | while read pane; do
    open_in_existing_pane $pane "$@"
  done
done

open_in_new_window $session:$window "$@"

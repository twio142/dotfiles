#!/bin/zsh

# Open files in nvim in the current pane if it is nvim
# Otherwise open in a new window
# Usage: [NEWW=1] open_in_vim.sh <client_pid> [-n] <file>...
# NEWW=1|-n: Open in a new window

open_in_existing_pane() {
  pane=$1
  shift
  local win cmd pid
  read win cmd pid <<< $pane
  case $cmd in
    nvim)
      until (ps -o command= -p $pid | grep -Eq "^nvim --embed"); do
        pid=$(pgrep -P $pid 2> /dev/null)
        [ -z "$pid" ] && break
      done
      local socket=$(find $TMPDIR -type s -path "*nvim.$pid.*" 2> /dev/null)
      [ -n "$socket" ] && {
        [ $# -gt 0 ] && nvim --server $socket --remote-tab "$@";
        exit 0;
      }
      ;;
    zsh)
      local line=$(tmux capture-pane -p -t $win -E - | grep -v '^\s*$' | tail -n1)
      if [[ "$line" = ❯ ]]; then
        cmd="vim"
        for file in $@; do
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
    cmd+=" ${file:q}"
  done
  tmux send-keys -t $pane "$cmd" Enter
}

getSession() {
  tmux lsc -F '#{client_pid}	#{client_session}' | awk -F '\t' -v pid="$1" '$1 == pid {print $2}'
}

session=$(getSession $1)
[ -z "$session" ] && exit 1
shift

if [ "$1" = -n ]; then
  shift
elif [ "$NEWW" != 1 ]; then
  tmux list-windows -t "$session" -F "#{window_active}	#{window_index}" | awk -F '\t' '$1 == "1" {print $2}' | while read window; do
    tmux list-panes -t "$session:$window" -F "#S:#{window_index}.#P	#{pane_current_command}	#{pane_pid}" | while read pane; do
      open_in_existing_pane $pane "$@"
    done
  done
fi

open_in_new_window $session:$window "$@"

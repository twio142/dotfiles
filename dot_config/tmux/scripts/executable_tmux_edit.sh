#!/bin/zsh

# Open files in nvim in the current pane if it is nvim
# Otherwise open in a new window
# Usage: [NEWW=1] [SESS=...] [PID=...] tmux_edit <file>...
# NEWW=1: Open in a new window
# SESS: Session name. If given, PID is ignored
# PID: Client PID

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
        [ -z "$pid" ] && return
      done
      local socket=$(nvr --serverlist | grep "nvim\.$pid\..*")
      [ -n "$socket" ] && {
        if [[ $# -eq 2 && -f "$1" && "$2" =~ '^[+ ][0-9]+$' ]]; then
          nvr --servername $socket "$1" -c "${2:1}"
        elif [ $# -gt 0 ]; then
          nvr --servername $socket "$@"
        fi
        exit 0;
      }
      ;;
    zsh)
      local line=$(tmux capturep -p -t $win -E - | grep -v '^\s*$' | tail -n1)
      if [[ "$line" = ❯ ]]; then
        cmd="nvim"
        for file in $@; do
          file=$(echo $file | sd '^ (\d+)$' '+$1')
          cmd+=" ${file:q}"
        done
        tmux send -t $win "$cmd" Enter
        exit 0
      fi
      ;;
  esac
}

open_in_new_window() {
  local window=$1
  shift
  tmux neww -t "$window" -c "$HOME"
  local pane=$(tmux display -t "${window%:*}" -p "#P")
  local cmd="nvim"
  for file in $@; do
    file=$(echo $file | sd '^ (\d+)$' '+$1')
    cmd+=" ${file:q}"
  done
  tmux send -t $pane "$cmd" Enter
}

getSession() {
  [ -z "$1" ] &&
    tmux display -p '#S' ||
    tmux lsc -F '#{client_pid}	#{client_session}' | awk -F '\t' -v pid="$1" '$1 == pid {print $2}'
}

if [ -z "$SESS" ]; then
  SESS=$(getSession "$PID")
fi
[ -z "$SESS" ] && exit 1

tmux lsw -t "$SESS:" -F "#{window_active}	#{window_index}" | awk -F '\t' '$1 == "1" {print $2}' | while read window; do
  tmux lsp -t "$SESS:$window" -F "#{pane_active}	#S:#{window_index}.#P	#{pane_current_command}	#{pane_pid}" | awk -F '\t' '$1 == "1" { $1=""; print $0 }' | while read pane; do
    open_in_existing_pane $pane "$@"
  done
done

open_in_new_window $SESS:$window "$@"

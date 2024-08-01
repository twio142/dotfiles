#!/bin/zsh

# Open files in nvim in the current pane if it is nvim
# Otherwise open in a new window

open_in_existing_pane() {
  pane=$1
  shift
  local id=$(echo $pane | cut -f1)
  local cmd=$(echo $pane | cut -f2)
  local pane_pid=$(echo $pane | cut -f3)
  case $cmd in
    nvim)
      local shell_pid=$(pgrep -P $pane_pid)
      local nvim_pid=$(pgrep -P $shell_pid)
      local socket_pid=$(pgrep -P $nvim_pid)
      local nvim_socket=$(find $TMPDIR -type s -name "nvim.${socket_pid}.*" 2>/dev/null | head -n 1)
      [ -z "$nvim_socket" ] || {
        [ $# -gt 0 ] && nvim --server $nvim_socket --remote-tab "$@";
        exit 0;
      }
      ;;
    zsh)
      line=$(tmux capture-pane -p -t $id -E - | grep -v '^\s*$' | tail -n1)
      if [[ "$line" = ❯ ]]; then
        tmux send-keys -t $id "$2"
        exit 0
      fi
      ;;
  esac
}

open_in_new_window() {
  local session=$1
  shift
  tmux new-window -t "$session"
  local pane=$(tmux display -t "$session" -p "#P")
  tmux send-keys -t "$pane" "nvim $@" Enter
}

tmux list-sessions -F "#{session_name}" | while read session; do
  tmux list-windows -t "$session" -F "#{window_index}	#{window_active}	#{window_panes}" | while read window; do
    window_active=$(echo $window | cut -f2)
    window_panes=$(echo $window | cut -f3)
    window=$(echo $window | cut -f1)
    if [[ "$window_active" = 1 && "$window_panes" = 1 ]]; then
      tmux list-panes -t "$session:$window" -F "#S:#{window_index}.#P	#{pane_current_command}	#{pane_pid}" | while read pane; do
        open_in_existing_pane $pane "$@"
      done
    fi
  done
  open_in_new_window $session "$@" && exit 0;
done

exit 1;

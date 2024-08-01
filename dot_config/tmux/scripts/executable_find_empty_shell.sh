#!/bin/zsh

# Check the frontmost process of the session of the given client

getSession() {
  tmux lsc -F '#{client_pid}	#S' | while read client; do
    local pid=$(echo $client | cut -f1)
    local sess=$(echo $client | cut -f2)
    if [[ "$pid" = $1 ]]; then
      echo $sess
      return
    fi
  done
}

session=$(getSession $1)
[ -z "$session" ] && exit 1

tmux lsw -t "$session" -F '#S:#{window_index}.#P	#{window_panes}	#{pane_current_command}' | while read window; do
  panes=$(echo $window | cut -f2)
  cmd=$(echo $window | cut -f3)
  id=$(echo $window | cut -f1)
  if [[ "$panes" = 1 && "$cmd" = zsh ]]; then
    line=$(tmux capture-pane -p -t $id -E - | grep -v '^\s*$' | tail -n1)
    if [[ "$line" = ❯ ]]; then
      tmux send-keys -t $id "$2"
      exit 0
    fi
  fi
done

tmux new-window -t "$session"

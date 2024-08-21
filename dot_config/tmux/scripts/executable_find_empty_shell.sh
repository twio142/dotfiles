#!/bin/zsh

# Check the frontmost process of the session of the given client

getSession() {
  tmux lsc -F '#{client_pid}	#{client_session}' | awk -F '\t' -v pid="$1" '$1 == pid {print $2}'
}

session=$(getSession $1)
[ -z "$session" ] && exit 1

enter() {
  [ -z "$1" ] && return
  echo $1 | tmux load-buffer -
  tmux paste-buffer -t "$session" -d
}

tmux lsw -t "$session" -F '#{window_panes}	#{pane_current_command}	#S:#{window_index}.#P' | awk -F '\t' '$1 == "1" && $2 == "zsh" {print $3}' | while read win; do
  line=$(tmux capture-pane -p -t $win -E - | grep -v '^\s*$' | tail -n1)
  if [[ "$line" = ❯ ]]; then
    enter $2
    exit 0
  fi
done

dir=$HOME
if [[ "$2" = cd && -e "$3" ]]; then
  [ -d $3 ] && dir=$3 || dir=$(dirname $3)
  shift 2
fi
tmux new-window -t "${win%.*}" -c "$dir"
enter $2

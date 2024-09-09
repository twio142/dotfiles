#!/bin/zsh

# Check the frontmost process of the session of the given client
# Usage: [NEWW=1] [SESS=...] find_empty_shell.sh <client_pid> [-n] [cd] ...
# NEWW=1|-n: Open in a new window
# SESS: Session name. If given, client_pid is ignored
# cd: Change to the directory; otherwise send the command to the shell

getSession() {
  tmux lsc -F '#{client_pid}	#{client_session}' | awk -F '\t' -v pid="$1" '$1 == pid {print $2}'
}

enter() {
  [ -z "$1" ] && return
  [[ "$1" = cd && -f "$2" ]] && 2=${2:h}
  echo "$@" | tmux load-buffer -
  tmux paste-buffer -t "$session" -d
}

[ -z "$SESS" ] && {
  session=$(getSession $1)
  shift
} || session=$SESS
[ -z "$session" ] && exit 1

if [ "$1" = -n ]; then
  shift
elif [ "$NEWW" != 1 ]; then
  tmux lsw -t "$session" -F '#{window_active}	#{pane_current_command}	#S:#{window_index}.#P' | awk -F '\t' '$1 == "1" && $2 == "zsh" {print $3}' | while read win; do
    line=$(tmux capture-pane -p -t $win -E - | grep -v '^\s*$' | tail -n1)
    if [[ "$line" = ❯ ]]; then
      enter "$@"
      exit 0
    fi
  done
fi

dir=$HOME
if [[ "$1" = cd && -e "$2" ]]; then
  [ -d $2 ] && dir=$2 || dir=$(dirname $2)
  shift 2
fi
tmux new-window -t "${win%.*}" -c "$dir"
enter "$@"

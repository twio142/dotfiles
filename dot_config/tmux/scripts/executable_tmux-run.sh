#!/bin/zsh

# Check the frontmost process of the session of the given client
# Usage: [NEWW=1] [SESS=...] [PID=...] tmux-run [cd|ssh|nvim] ...
# NEWW=1: Run command in a new window
# PID: Client PID
# SESS: Session name. If given, PID is ignored
# cd: Change to the directory; otherwise send the command to the shell
# ssh: Open an ssh connection to the given host
# nvim: Run tmux-edit

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  echo "Usage: $(basename "$0") [command] [args...]"
  echo
  echo "Runs a command in the current tmux session."
  echo "The script intelligently finds an empty shell prompt to run
the command."
  echo "If it can't, or if NEWW=1 is set, it runs the command in a new
window."
  echo
  echo "Special Commands:"
  echo "  cd <path>    Changes directory in a new or existing pane."
  echo "  ssh <host>   Opens a new window and connects to the host."
  echo "  nvim <file>  Edits a file using the 'tmux-edit.sh' script."
  echo
  echo "Environment Variables:"
  echo "  NEWW=1      Force the command to run in a new window."
  echo "  SESS=<name> Specify the target tmux session name."
  echo "  PID=<pid>   Specify the client PID to find the target
session."
  exit 0
fi

getSession() {
  # if no client_pid is given, return current session
  [ -z "$1" ] &&
    tmux display -p '#S' ||
    tmux lsc -F '#{client_pid}	#{client_session}' | awk -F '\t' -v pid="$1" '$1 == pid {print $2}'
}

enter() {
  # enter the command into the shell
  [ -z "$1" ] && return
  [[ "$1" = cd && -f "$2" ]] && 2=${2:h}
  [[ "$1" = cd && -d "$2" ]] && 2=${2:q}
  echo "${@}" | tmux loadb -
  tmux pasteb -d
}

if [ -z "$SESS" ]; then
  SESS=$(getSession "$PID")
fi
[ -z "$SESS" ] && exit 1

# if the command is ssh, open a new window
if [[ "$1" = ssh && -n "$2" ]]; then
  tmux neww -t "$SESS:" "ssh $2"
  exit 0
fi

# if the command is nvim, run tmux-edit
if [[ "$1" = nvim ]]; then
  shift
  ~/.local/bin/tmux-edit "$@"
  exit 0
fi

# determine the window to use
# NEWW=1 / -n: force open in a new window
if [ "$NEWW" != 1 ]; then
  # see if the current window is an empty shell
  tmux lsw -t "$SESS:" -F '#{window_active}	#{pane_current_command}	#S:#{window_index}.#P' | awk -F '\t' '$1 == "1" && $2 == "zsh" {print $3}' | while read win; do
    line=$(tmux capturep -p -t $win -E - | grep -v '^\s*$' | tail -n1)
    if [[ "$line" = ❯ ]]; then
      enter "$@"
      exit 0
    fi
  done
fi

# no empty shell found, open a new window

# if the command is cd, change to the directory
# otherwise, open the new window in home directory
PWD=$HOME
if [[ "$1" = cd && -e "$2" ]]; then
  [ -d "$2" ] && PWD=$2 || PWD=$(dirname $2)
  shift 2
fi
tmux neww -t "$SESS:" -c "$PWD"
enter "$@"

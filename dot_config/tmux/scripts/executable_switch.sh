#!/bin/zsh

case $1 in
  h) flag=L; test=left;;
  j) flag=D; test=bottom;;
  k) flag=U; test=top;;
  l) flag=R; test=right;;
  *) exit 1 ;;
esac

cmd=$(tmux display-message -p "#{pane_current_command}")
test=$(tmux display-message -p "#{pane_at_${test}}")
[[ "$cmd" == nvim || "$test" == 1 ]] &&
  tmux send-keys C-$1 ||
  tmux select-pane -${flag}

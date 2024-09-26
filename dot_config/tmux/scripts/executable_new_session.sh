#!/bin/zsh

i=0
while [ $i -lt 10 ]; do
  tmux has -t $i 2>/dev/null || { tmux new -s $i; return; }
  i=$((i+1))
done
tmux new;

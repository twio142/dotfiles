#!/bin/zsh

export PATH="$HOME/.local/bin:$PATH"
export EDITOR=nvim
export LESS="-r"
export LESSHISTFILE=$XDG_STATE_HOME/less/history
export PAGER="bat --style=plain --color=always --paging=always --pager=less"
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind='ctrl-d:preview-half-page-down' --bind='ctrl-u:preview-half-page-up'"
export LS_COLORS="$(vivid generate one-light)"

if [ "$1" = "--jump" ]; then
  cwd=$(fzf --bind "start:reload:zoxide query '' -l | awk '{ if (!seen[tolower()]++) print }' || true" \
  --bind "change:reload:zoxide query {q} -l | awk '{ if (!seen[tolower()]++) print }' || true" \
  --bind "ctrl-o:execute(tmux neww -c {})+abort" \
  --bind "ctrl-x:reload:zoxide remove '{}' && zoxide query {q} -l | awk '{ if (!seen[tolower()]++) print }' || true" \
  --disabled \
  --preview "fzf-preview {}" \
  --height=~60%) && xplr $cwd || exit 0
elif [ -d "$1" ]; then
  xplr "$1"
else
  xplr
fi

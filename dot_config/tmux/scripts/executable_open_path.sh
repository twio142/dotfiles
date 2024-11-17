#!/bin/zsh

export PATH="$HOME/.local/bin:$PATH"
export EDITOR=nvim
export LESS="-r"
export LESSHISTFILE=$XDG_STATE_HOME/less/history
export PAGER="bat --style=plain --color=always --paging=always --pager=less"
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --bind='ctrl-d:preview-half-page-down' --bind='ctrl-u:preview-half-page-up' --bind='alt-j:jump'"
export LS_COLORS="$(vivid generate one-light)"

BOLD=$'\033[1;36m'
OFF=$'\033[0m'

cwd=$(fzf --bind "start:reload:zoxide query '' -l | awk '{ if (!seen[tolower()]++) print }' || true" \
--header "${BOLD}^E${OFF} explore / ${BOLD}^G${OFF} lazygit / ${BOLD}^S${OFF} split / ${BOLD}^V${OFF} vsplit" \
--bind "change:reload:eval zoxide query {q} -l | awk '{ if (!seen[tolower()]++) print }' || true" \
--bind "ctrl-s:execute(tmux splitw -v -l 35% -c {})+abort" \
--bind "ctrl-v:execute(tmux splitw -h -c {})+abort" \
--bind "ctrl-g:execute(lazygit -p {})" \
--bind "enter:execute(tmux neww -c {})+abort" \
--bind "ctrl-e:accept" \
--bind "ctrl-x:reload:zoxide remove {} && eval zoxide query {q} -l | awk '{ if (!seen[tolower()]++) print }' || true" \
--disabled \
--preview "fzf-preview {}" \
--preview-window='up,60%')
[ -n "$cwd" ] && xplr $cwd || exit 0

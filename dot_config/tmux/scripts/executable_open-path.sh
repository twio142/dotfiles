#!/bin/zsh

# Open a directory from zoxide in a new tmux window or pane

BOLD=$'\033[1;36m'
OFF=$'\033[0m'

fzf --bind "start:reload:zoxide query '' -l | awk '{ if (!seen[tolower()]++) print }' || true" \
--header "${BOLD}^E${OFF} explore / ${BOLD}^G${OFF} lazygit / ${BOLD}^S${OFF} split / ${BOLD}^V${OFF} vsplit" \
--bind "change:reload:eval zoxide query {q} -l | awk '{ if (!seen[tolower()]++) print }' || true" \
--bind "enter:execute(tmux neww -c {})+abort" \
--bind "ctrl-s:execute(tmux splitw -v -l 35% -c {})+abort" \
--bind "ctrl-v:execute(tmux splitw -h -c {})+abort" \
--bind "ctrl-g:execute(lazygit -p {})" \
--bind "ctrl-e:execute(nvim -u $XDG_CONFIG_HOME/tmux/custom/yazi_init.lua {})" \
--bind "ctrl-x:reload:zoxide remove {} && eval zoxide query {q} -l | awk '{ if (!seen[tolower()]++) print }' || true" \
--disabled \
--preview "fzf-preview {}" \
--preview-window='up,60%'

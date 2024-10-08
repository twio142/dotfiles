#!/bin/zsh
PATH=/opt/homebrew/bin:$PATH

## Search for text in files using Ripgrep and open in Vim
## by default, open files in vim
## with `-o`, write file path to stdout

# rg_prefix='rg --column --line-number --no-heading --color=always --smart-case'
# fzf --bind "start:reload:$rg_prefix '' || true" \
#     --bind "change:reload:$rg_prefix {q} || true" \
#     --bind 'enter:become(nvim {1} +{2})' \
#     --ansi --disabled \
#     --delimiter ':' \
#     --preview 'sed -n {2}p {1} 2>/dev/null | rg --color=always --smart-case {q}' \
#     --preview-window wrap

# 1. Search for text in files using Ripgrep
# 2. Interactively narrow down the list using fzf
# 3. Open the file in Vim
# rg --ignore-vcs --glob '!**/.git/**' --color=always --line-number --no-heading --smart-case "${*:-}" |
#   fzf --ansi \
#       --color "hl:-1:underline,hl+:-1:underline:reverse" \
#       --delimiter : \
#       --preview 'bat --color=always {1} --highlight-line {2}' \
#       --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
#       --bind 'enter:become(nvim {1} +{2})'

PURPLE=$'\033[35m'
OFF=$'\033[0m'
FD_PREFIX="fd -H -L -tf -E .git -E .DS_Store -p "
FD_SUFFIX=". -X ls -t | sed 's/^\.\//${PURPLE}/' | sed 's/\$/${OFF}/'"
RG="rg --ignore-vcs -g '!**/.git/**' -L --column --line-number --no-heading --color=always --smart-case"
COPY=pbcopy
[ -n "$TMUX" ] && COPY="tmux load-buffer -"

[ "$1" = -o ] && { enter="become(for i in {+1..2}; do echo \$i; done)"; shift; } || enter="become([[ \$(echo {+n} | awk '{print NF}') -gt 1 || -z {2} ]] && nvim {+1} || nvim {1} +{2})"
INITIAL_QUERY="${*:-}"

fzf --ansi --disabled --query "$INITIAL_QUERY" -m \
    --color "hl:-1:underline,hl+:-1:underline:reverse" \
    --bind "start:reload:$FD_PREFIX . $FD_SUFFIX" \
    --bind "change:reload:sleep 0.1; $FD_PREFIX {q} $FD_SUFFIX || true; $RG {q} || true" \
    --bind "ctrl-y:execute-silent(echo {1} | $COPY)" \
    --bind "ctrl-f:unbind(change,ctrl-f)+change-prompt(fzf > )+enable-search+reload($RG . || true)" \
    --bind "enter:$enter" \
    --delimiter : \
    --preview '[ -z {2} ] && bat --color=always {} || bat --color=always {1} --highlight-line {2}' \
    --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'

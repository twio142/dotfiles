#!/bin/zsh
PATH=/opt/homebrew/bin:$PATH

## Search in Obsidian vault using fd and ripgrep
## by default, open files in vim
## with `-o`, write file path to stdout

VAULT=${VAULT:-$HOME/iCloud/Markdown}
cd $VAULT &> /dev/null || exit 1
PURPLE=$'\033[35m'
OFF=$'\033[0m'
FD_PREFIX="fd -H -L -tf -e md -E .trash -E .obsidian -p "
FD_SUFFIX=". -X ls -t | sed 's/^\.\//${PURPLE}/' | sed 's/\$/${OFF}/'"
RG="rg --ignore-vcs -t markdown -g '!**/.obsidian/**' -ig '!**/.trash/**' -L --column --line-number --no-heading --color=always --smart-case"
COPY=pbcopy
[ -n "$TMUX" ] && COPY="tmux load-buffer -"

[ "$1" = -o ] && { enter="become(for i in {+1..2}; do echo $VAULT/\$i; done)"; shift; } || enter="execute([[ \$(echo {+n} | awk '{print NF}') -gt 1 || -z {2} ]] && nvim {+1} || nvim {1} +{2})"
INITIAL_QUERY="${*:-}"

fzf --ansi --disabled --query "$INITIAL_QUERY" -m \
    --color "hl:-1:underline,hl+:-1:underline:reverse" \
    --bind "start:reload:$FD_PREFIX . $FD_SUFFIX" \
    --bind "change:reload:sleep 0.1; $FD_PREFIX {q} $FD_SUFFIX || true; $RG {q} || true" \
    --bind "ctrl-y:execute-silent(echo '[['{1} | sd '\.md$' ']]' | $COPY)" \
    --bind "ctrl-f:unbind(change,ctrl-f)+change-prompt(fzf > )+enable-search+reload($RG . || true)" \
    --bind "enter:$enter" \
    --delimiter : \
    --preview '[ -z {2} ] && bat --color=always {} || bat --color=always {1} --highlight-line {2}' \
    --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'

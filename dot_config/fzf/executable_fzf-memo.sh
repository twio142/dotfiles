#!/bin/zsh

# FZF Memo - A simple memo manager using fzf and nvim

scpt=~/Projects/Uebersicht/Memos.widget/lib/actions.mjs
data=~/Projects/Uebersicht/Memos.widget/lib/data.json

case "$1" in
  new)
    file=/tmp/memo.0.md
    trap 'rm -f "$file"' EXIT
    nvim +startinsert -- $file && [ -f $file ] &&
      cat $file | $scpt new &> /dev/null || true;
    exit 0
    ;;
  -h|--help)
    echo "Usage: $(basename "$0")"
    echo
    echo "A simple memo manager using fzf and nvim."
    exit 0
    ;;
esac

COPY=pbcopy
[ -n "$TMUX" ] && COPY="tmux loadb -"

BOLD=$'\033[1;36m'
OFF=$'\033[0m'

reload="cat \"$data\" | jq -r 'to_entries | .[] | ((.value.text | sub(\"\n\";\"\";\"gm\")) + \"\t\" + .key)' | tr '\\n' '\\0' | sd '' '\n'"

cat "$data" | \
  jq -r 'to_entries | .[] | ((.value.text | sub("\n";"";"gm")) + "\t" + .key)' | \
  tr '\n' '\0' | sd '' '\n' | \
  fzf --read0 -d '\t' --with-nth=1 \
  --preview "echo {1} | bat -l md" --preview-window=up,60%,wrap \
  --header="${BOLD}^C${OFF} create /${BOLD}^X${OFF} delete / ${BOLD}^Y${OFF} yank" \
  --bind "ctrl-y:execute-silent(printf {1} | $COPY)" \
  --bind "ctrl-x:execute(\"$scpt\" delete {2})+reload($reload)" \
  --bind "ctrl-c:execute(nvim /tmp/memo.0.md +startinsert && cat /tmp/memo.0.md | \"$scpt\" new &> /dev/null || true; rm /tmp/memo.0.md)+reload($reload)" \
  --bind "enter:execute(printf {1} > /tmp/memo.{2}.md; nvim /tmp/memo.{2}.md && cat /tmp/memo.{2}.md | \"$scpt\" edit {2} &> /dev/null || true; rm /tmp/memo.{2}.md)+reload($reload)"

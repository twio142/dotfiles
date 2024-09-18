#!/bin/zsh

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
# [ -z $alfred_version ] && . ${XDG_CONFIG_HOME:-~/.config}/fzf/fzf-git.sh

export FZF_DEFAULT_OPTS='--layout=reverse --cycle --inline-info --color=fg+:-1,bg+:-1,hl:bright-red,hl+:red,pointer:bright-red,info:-1,prompt:-1 --pointer= --bind="ctrl-d:preview-half-page-down" --bind="ctrl-u:preview-half-page-up"'

# Use `` as the trigger sequence instead of the default **
export FZF_COMPLETION_TRIGGER="\`"
# Options to fzf command
export FZF_COMPLETION_OPTS="$FZF_DEFAULT_OPTS"
export FZF_CTRL_R_OPTS="-d '\t' --with-nth 2.. --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'"
export FZF_ALT_C_OPTS=" --walker-skip .git,node_modules,target,__pycache__ --preview '$XDG_CONFIG_HOME/fzf/fzf-preview.sh {}'"
# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd -H -L --exclude ".DS_Store" --exclude ".git" . "$1" --exec-batch stat -f "%m %N" \; | sort -rn | choose 1..
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d -H -L --exclude ".git" . "$1" --exec-batch stat -f "%m %N" \; | sort -rn | choose 1..
}

fzf-history-widget() {
  # enter -> execute; ctrl-e -> edit
  local selected
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases noglob nobash_rematch 2> /dev/null
  if zmodload -F zsh/parameter p:history 2>/dev/null && (( ${#commands[perl]} )); then
    selected="$(printf '%s\t%s\000' "${(kv)history[@]}" |
      perl -0 -ne 'if (!$seen{(/^\s*[0-9]+\**\t(.*)/s, $1)}++) { s/\n/\n\t/g; print; }' |
      FZF_DEFAULT_OPTS=$(__fzf_defaults "" "-n2..,.. --scheme=history --bind=ctrl-r:toggle-sort --wrap-sign '\t↳ ' --highlight-line ${FZF_CTRL_R_OPTS-} --expect=ctrl-e --query=${(qqq)LBUFFER} +m --read0") \
      FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd))"
  else
    selected="$(fc -rl 1 | awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, "", cmd); if (!seen[cmd]++) print $0 }' |
      FZF_DEFAULT_OPTS=$(__fzf_defaults "" "-n2..,.. --scheme=history --bind=ctrl-r:toggle-sort --wrap-sign '\t↳ ' --highlight-line ${FZF_CTRL_R_OPTS-} --expect=ctrl-e --query=${(qqq)LBUFFER} +m") \
      FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd))"
  fi
  local ret=$?
  if [ -n "$selected" ]; then
    if [[ $(sed -n '$=' <<<"$selected") -eq 1 ]]; then
      [[ $selected == "ctrl-e" ]] && LBUFFER="$selected"
    elif [[ $(sed '1d' <<<"$selected") =~ ^[[:space:]]*[[:digit:]]+ ]]; then
      zle vi-fetch-history -n "$MATCH"
      [[ $(sed 'q' <<<"$selected") != "ctrl-e" ]] && zle accept-line
    fi
  fi
  zle reset-prompt
  return $ret
}

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview "$XDG_CONFIG_HOME/fzf/fzf-preview.sh {}" "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    vim)          shift 2; $XDG_CONFIG_HOME/fzf/fzf-search-file.sh "${*:-}";;
    chezmoi)      chezmoi managed -p absolute | fzf --preview "$XDG_CONFIG_HOME/fzf/fzf-preview.sh {}" --bind "ctrl-f:reload(chezmoi status -i files -p absolute | choose 1..)+change-preview(chezmoi diff {})+change-header( Unstaged files )" "$@" ;;
    *)            fzf --preview "$XDG_CONFIG_HOME/fzf/fzf-preview.sh {}" "$@" ;;
  esac
}

_autojump_fzf() {
  local query=${LBUFFER##* }
  LBUFFER=''
  local dir=$(fzf --query=${query} --bind "start:reload:zoxide query '${query}' -l | awk '{ if (!seen[tolower()]++) print }'" \
    --bind "change:reload:zoxide query '{q}' -l | awk '{ if (!seen[tolower()]++) print }'" \
    --bind "ctrl-x:reload(zoxide remove '{}' && zoxide query '{q}' -l | awk '{ if (!seen[tolower()]++) print }')" \
    --disabled \
    --preview "$XDG_CONFIG_HOME/fzf/fzf-preview.sh {}" \
    --height=30%)
  if [[ -z "$dir" || ! -d "$dir" ]]; then
    zle redisplay
    return 0
  fi
  zle push-line
  BUFFER="builtin cd -- ${(q)dir:a}"
  zle accept-line
  local ret=$?
  zle reset-prompt
  return $ret
}
zle -N _autojump_fzf

# _fzf_image() {
#   local query=${LBUFFER##* }
#   LBUFFER=''
#   local selected=$(fd --exclude ".git" -e jpg -e jpeg -e png -e gif -e bmp -e tiff -e webp | fzf -m --query=${query} --preview "$XDG_CONFIG_HOME/fzf/fzf-preview.sh {}" --preview-window='bottom,80%')
#   local ret=$?
#   if [ -n "$selected" ]; then
#     LBUFFER=${LBUFFER% *}
#     echo $selected | while read -r line; do
#       LBUFFER+=\ ${line:q}
#     done
#   fi
#   zle reset-prompt
#   return $ret
# }
# zle -N _fzf_image

_fzf_repos() {
  local query=${LBUFFER##* }
  LBUFFER=''
  local dir=$(awk '/recentrepos:/ {found=1; next} found && /^[^[:space:]]/ {exit} found {print}' $XDG_STATE_HOME/lazygit/state.yml | sd '^ +- ' '' | grep -Fxv "$PWD" | fzf --query=${query} --preview "echo -e \"\033[1m\$(basename {})\033[0m\n\"; git -c color.status=always -C {} status -bs" --preview-window='wrap' --height=~50%)
  local ret=$?
  if [ -z "$dir" ]; then
    zle redisplay
    return 0
  fi
  zle push-line
  BUFFER="builtin cd -- ${(q)dir:a}"
  zle accept-line
  local ret=$?
  zle reset-prompt
  return $ret
}
zle -N _fzf_repos

bindkey '^[g' _autojump_fzf
bindkey '^[r' _fzf_repos
# bindkey '^Xi' _fzf_image

#!/bin/zsh

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

## ctrl-d / ctrl-u: scroll preview
## alt-j: jump
export FZF_DEFAULT_OPTS='--layout=reverse --cycle --inline-info --color=fg+:-1,bg+:-1,hl:bright-red,hl+:red,pointer:bright-red,info:-1,prompt:-1 --pointer= --bind="ctrl-d:preview-half-page-down" --bind="ctrl-u:preview-half-page-up" --bind="alt-j:jump"'

# Use ` as the trigger sequence instead of the default **
export FZF_COMPLETION_TRIGGER='`'
# Commands and options to fzf command
export FZF_COMPLETION_OPTS="$FZF_DEFAULT_OPTS"

# CTRL-R: search history
## ctrl-y -> yank
COPY=pbcopy
[ -n "$TMUX" ] && COPY="tmux load-buffer -"
export FZF_CTRL_R_OPTS="-d '\t' --with-nth 2.. --bind 'ctrl-y:execute-silent(printf {2..} | $COPY)+abort'"
unset COPY

# CTRL-T: search files
# ALT-C: search directories
## alt-i -> toggle ignore vcs
export FZF_CTRL_T_COMMAND='fd -H -L'
NO_IGNORE='--no-ignore-vcs --strip-cwd-prefix=always'
export FZF_CTRL_T_OPTS="--preview 'fzf-preview {}' -m --bind \"alt-i:clear-query+transform-prompt( [ \$FZF_PROMPT = '> ' ] && echo ' > ' || echo '> ' )+reload( [ \$FZF_PROMPT = '> ' ] && $FZF_CTRL_T_COMMAND || $FZF_CTRL_T_COMMAND $NO_IGNORE )\""
export FZF_ALT_C_COMMAND='fd -td -H -L'
export FZF_ALT_C_OPTS="--preview 'fzf-preview {}' -m --bind \"alt-i:clear-query+transform-prompt( [ \$FZF_PROMPT = '> ' ] && echo ' > ' || echo '> ' )+reload( [ \$FZF_PROMPT = '> ' ] && $FZF_ALT_C_COMMAND || $FZF_ALT_C_COMMAND $NO_IGNORE )\""

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd -H -L . "${@:-.}" | sd '^./' ''
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd -td -H -L . "${@:-.}" | sd '^./' ''
}

fzf-history-widget() {
  # enter -> execute; ctrl-e -> edit; ctrl-s -> toggle-sort
  local selected
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases noglob nobash_rematch 2> /dev/null
  if zmodload -F zsh/parameter p:history 2>/dev/null && (( ${#commands[perl]} )); then
    selected="$(printf '%s\t%s\000' "${(kv)history[@]}" |
      perl -0 -ne 'if (!$seen{(/^\s*[0-9]+\**\t(.*)/s, $1)}++) { s/\n/\n\t/g; print; }' |
      FZF_DEFAULT_OPTS=$(__fzf_defaults "" "-n2..,.. --scheme=history --bind=ctrl-s:toggle-sort --wrap-sign '\t↳ ' --highlight-line ${FZF_CTRL_R_OPTS-} --expect=ctrl-e --query=${(qqq)LBUFFER} +m --read0") \
      FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd))"
  else
    selected="$(fc -rl 1 | awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, "", cmd); if (!seen[cmd]++) print $0 }' |
      FZF_DEFAULT_OPTS=$(__fzf_defaults "" "-n2..,.. --scheme=history --bind=ctrl-s:toggle-sort --wrap-sign '\t↳ ' --highlight-line ${FZF_CTRL_R_OPTS-} --expect=ctrl-e --query=${(qqq)LBUFFER} +m") \
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
    cd)           fzf --preview "fzf-preview {}" "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    vim|nvim)     local FD='fd -tf -H -L'
                  fzf --preview "fzf-preview {}" \
                      --bind "change:transform:[ \$FZF_PROMPT = '> ' ] || echo 'reload($FD '{q}' . -X ls -t)'" \
                      --bind "ctrl-s:clear-query+toggle-search+transform-prompt( [ \$FZF_PROMPT = '> ' ] && echo ' > ' || echo '> ')+reload([ \$FZF_PROMPT = '> ' ] && $FD --strip-cwd-prefix=always . || $FD . . -X ls -t)" "$@" ;;
                  # ctrl-s -> sort by mtime
    chezmoi)      chezmoi managed -p absolute | fzf --preview "fzf-preview {}" \
                      --bind "ctrl-f:reload(chezmoi status -i files -p absolute | choose 1..)+change-preview(chezmoi diff {})+change-header( Changed files )" "$@" ;;
                  # ctrl-f -> filter changed files
    *)            fzf --preview "fzf-preview {}" "$@" ;;
  esac
}

# search for a directory using zoxide, and enter it
_autojump_fzf() {
  # ctrl-x -> remove from history
  local query=${LBUFFER##* }
  LBUFFER=''
  local dir=$(fzf --query=${query} --bind "start:reload:zoxide query {q} -l --exclude '${PWD}' || true" \
    --bind "change:reload:eval zoxide query {q} -l --exclude ${PWD:q:q} || true" \
    --bind "ctrl-x:reload:zoxide remove {} && eval zoxide query {q} -l --exclude ${PWD:q:q} || true" \
    --disabled \
    --preview "fzf-preview {}" \
    --height=30%)
  if [[ -z "$dir" || ! -d "$dir" ]]; then
    zle redisplay
    return 0
  fi
  zle push-line
  BUFFER="cd ${(q)dir:a}"
  zle accept-line
  local ret=$?
  zle reset-prompt
  return $ret
}
zle -N _autojump_fzf

# search for images in the current directory, and prompt into the command line
# _fzf_image() {
#   local query=${LBUFFER##* }
#   local selected=$(fd -e jpg -e jpeg -e png -e gif -e bmp -e tiff -e webp | fzf -m --query=${query} --preview "fzf-preview {}" --preview-window='bottom,80%')
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

# search for a git repository, and enter it
_fzf_repos() {
  # ctrl-e -> open in lazygit
  local query=${LBUFFER##* }
  LBUFFER=''
  local dir=$(awk '/recentrepos:/ {found=1; next} found && /^[^[:space:]]/ {exit} found {print}' $XDG_STATE_HOME/lazygit/state.yml | sd '^ +- ' '' | grep -Fxv "$PWD" | fzf --query=${query} --bind "ctrl-e:become(lazygit -p {})" --preview "echo -e \"\033[1m\$(basename {})\033[0m\n\"; git -c color.status=always -C {} status -bs" --preview-window='wrap' --height=~50%)
  local ret=$?
  if [ -z "$dir" ]; then
    zle redisplay
    return 0
  fi
  zle push-line
  BUFFER="cd ${(q)dir:a}"
  zle accept-line
  local ret=$?
  zle reset-prompt
  return $ret
}
zle -N _fzf_repos

# search for a directory, and then for files / directories inside it
# and prompt into the command line
_fzf_locate() {
  # alt-enter -> accept directory
  local query=${LBUFFER##* }
  local dir=$(fzf --query=${query} -m --bind "start:reload:zoxide query {q} -l --exclude '${PWD}' || true" \
    --bind "change:reload:eval zoxide query {q} -l --exclude ${PWD:q:q} || true" \
    --bind "alt-enter:print(accept)+accept" \
    --disabled \
    --preview "fzf-preview {}" \
    --height=30%) || return 0
  if [ "$(echo "$dir" | head -n1)" = accept ]; then
    local selected=$(echo "$dir" | sed 1d)
    [ -z "$selected" ] && return 0
    local ret=$?
    LBUFFER=${LBUFFER% *}
    echo $selected | while read -r line; do
      LBUFFER+=\ ${line:q}
    done
    zle reset-prompt
    return $ret
  fi
  dir=$(echo "$dir" | head -n1)
  [[ -z "$dir" || ! -d "$dir" ]] && return 0
  zle redisplay
  local selected=$(_fzf_compgen_path . --base-directory=$dir | fzf -m --preview "fzf-preview '$dir'/{}" --height=~50%) || return 0
  local ret=$?
  if [ -n "$selected" ]; then
    LBUFFER=${LBUFFER% *}
    echo $selected | while read -r line; do
      line=${line/#.\/}
      LBUFFER+=\ ${dir:q}\/${line:q}
    done
  fi
  zle reset-prompt
  return $ret
}
zle -N _fzf_locate

bindkey '^[t' fzf-file-widget
bindkey '^[g' _autojump_fzf
bindkey '^[r' _fzf_repos
bindkey '^[l' _fzf_locate
# bindkey '^Xi' _fzf_image

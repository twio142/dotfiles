#!/bin/zsh

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
# [ -z $alfred_version ] && . ${XDG_CONFIG_HOME:-~/.config}/fzf/fzf-git.sh

export FZF_DEFAULT_OPTS='--layout=reverse --cycle --inline-info --color=fg+:-1,bg+:-1,hl:bright-red,hl+:red,pointer:bright-red,info:-1,prompt:-1 --pointer= --bind="ctrl-d:preview-down" --bind="ctrl-u:preview-up"'

# Use `` as the trigger sequence instead of the default **
export FZF_COMPLETION_TRIGGER="\`\`"
# Options to fzf command
export FZF_COMPLETION_OPTS="$FZF_DEFAULT_OPTS"
export FZF_CTRL_R_OPTS="--bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'"
# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd -H -L --exclude ".DS_Store" --exclude ".git" . "$1" --exec-batch stat -f "%m %N" \; | sort -rn | choose 1
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d -H -L --exclude ".git" . "$1" --exec-batch stat -f "%m %N" \; | sort -rn | choose 1
}

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'tree -C {} -L 4' "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    vim)          fzf --preview "$XDG_CONFIG_HOME/fzf/fzf-preview.sh {}" --bind "ctrl-f:reload(cat $XDG_CACHE_HOME/neomru/file | sed '2,10!d')+change-header( Recent files )" "$@" ;;
    chezmoi)      chezmoi managed -p absolute | fzf --preview "$XDG_CONFIG_HOME/fzf/fzf-preview.sh {}" --bind "ctrl-f:reload(chezmoi status -i files -p absolute | choose 1..)+change-preview(chezmoi diff {})+change-header( Unstaged files )" "$@" ;;
    *)            fzf --preview "$XDG_CONFIG_HOME/fzf/fzf-preview.sh {}" "$@" ;;
  esac
}

_autojump_fzf() {
  [ -f $(brew --prefix)/etc/profile.d/autojump.sh ] || return 1
  [ -z $AUTOJUMP_SOURCED ] && source $(brew --prefix)/etc/profile.d/autojump.sh
  autojump --purge &> /dev/null
  local dir=$(fzf --bind "start:reload:autojump --complete '' | awk -F '__' '{ if (!seen[tolower(\$3)]++) print \$3 }'" \
    --bind "change:reload:autojump --complete '{q}' | awk -F '__' '{ if (!seen[tolower(\$3)]++) print \$3 }'" \
    --disabled \
    --preview 'tree -C {} -L 4' \
    --height=30%)
  if [[ -z "$dir" || ! -d "$dir" ]]
  then
    zle redisplay
    return 0
  fi
  zle push-line
  BUFFER="builtin cd -- ${(q)dir:a}"
  zle accept-line
  local ret=$?
  unset dir
  zle reset-prompt
  return $ret
}
zle -N _autojump_fzf

# _fzf_image() {
#   local query=${LBUFFER##* }
#   local selected=$(fd --exclude ".git" -e jpg -e jpeg -e png -e gif -e bmp -e tiff -e webp | fzf -m --query=${query} --preview "$XDG_CONFIG_HOME/fzf/fzf-preview.sh {}" --preview-window='bottom,80%')
#   local ret=$?
#   if [ -n "$selected" ]; then
#     LBUFFER=${LBUFFER% *}
#     echo $selected | while read -r line; do
#       LBUFFER+=\ ${line:q}
#     done
#   fi
#   unset query selected
#   zle reset-prompt
#   return $ret
# }
# zle -N _fzf_image

_fzf_repos() {
  local query=${LBUFFER##* }
  local dir=$(awk '/recentrepos:/ {found=1; next} found && /^[^[:space:]]/ {exit} found {print}' $XDG_STATE_HOME/lazygit/state.yml | sd '^ +- ' '' | grep -Fxv "$PWD" | fzf --query=${query} --preview "git -c color.status=always -C {} status | sd ' +\(use \"git [^)]+\)' ''" --preview-window='wrap')
  local ret=$?
  if [ -z "$dir" ]; then
    zle redisplay
    return 0
  fi
  zle push-line
  BUFFER="builtin cd -- ${(q)dir:a}"
  zle accept-line
  local ret=$?
  unset dir
  zle reset-prompt
  return $ret
}
zle -N _fzf_repos

bindkey '^[g' _autojump_fzf
bindkey '^[r' _fzf_repos
# bindkey '^Xi' _fzf_image

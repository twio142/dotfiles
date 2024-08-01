# You can put files here to add functionality separated per file, which
# will be ignored by git.
# Files on the custom/ directory will be automatically loaded by the init
# script, in alphabetical order.

# For example: add yourself some shortcuts to projects you often work on.
#
# brainstormr=~/Projects/development/planetargon/brainstormr
# cd $brainstormr
#

source ~/bin/ssh-completion

alias back='cd "$OLDPWD"'
alias gdv='git difftool -y -t nvimdiff'
alias ls=colorls
alias reconfig='omz reload'
alias vim=nvim

cn() { [ -z $1 ] && conda deactivate || conda activate $1 }
co() { 1="$*"; gh copilot suggest "$1" }
coe() { 1="$*"; gh copilot explain "$1" }
lc() {
    1=${1:a};
    [ -d $1 ] && cd $1 || cd ${1:h};
}
gitup() {
  1=${1:-$PWD}
  until [ -d $1/.git ]; do
    [ $1 = ${1:h} ] && {echo "Could not find repository" >&2; return 1;}
    1=${1:h}
  done
  open -b co.gitup.mac $1
}
gro() {
  local url=$(git config --get remote.origin.url)
  url=$(echo $url | perl -pe 's/.+(git(hub|lab).com)[:\/]([^\/]+\/[^\/]+?)/https:\/\/\1\/\3/g')
  [ -z $url ] || open $url
}
ipy() { ${1:-~/bin/py3} -m IPython }

export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_INSECURE_REDIRECT=1
# export HOMEBREW_CASK_OPTS=--require-sha
export HOMEBREW_NO_ENV_HINTS=1
# export HOMEBREW_NO_AUTO_UPDATE=1
export PYTHON3_HOST_PROG=$HOME/bin/py3
export PYTHON_HOST_PROG=$HOME/bin/py2

### FZF OPTIONS ###
export FZF_DEFAULT_OPTS='--layout=reverse --inline-info --color=fg+:-1,bg+:-1,hl:bright-red,hl+:red,pointer:bright-red,info:-1,prompt:-1 --pointer=➤'

# Use ~~ as the trigger sequence instead of the default **
export FZF_COMPLETION_TRIGGER='~~'
# Options to fzf command
export FZF_COMPLETION_OPTS="$FZF_DEFAULT_OPTS"
# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'tree -C {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}" --preview-window 'wrap'         "$@" ;;
    ssh)          fzf --preview 'dig {}' --preview-window 'wrap'                   "$@" ;;
    *)            fzf --preview '[ -f {} ] && bat -n --color=always {} || tree -C {} | head -200' --preview-window 'wrap' "$@" ;;
  esac
}

_autojump_fzf() { 
  autojump --purge &> /dev/null
  local dir=$(fzf --bind "start:reload:autojump --complete '' | awk -F '__' '{ if (!seen[tolower(\$3)]++) print \$3 }'" \
    --bind "change:reload:autojump --complete '{q}' | awk -F '__' '{ if (!seen[tolower(\$3)]++) print \$3 }'" \
    --disabled \
    --preview 'tree -C {} | head -200' \
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

# bindkey '^[[1;3A' history-beginning-search-backward
# bindkey '^[[1;3B' history-beginning-search-forward
[[ -n "$TMUX" ]] && {
  bindkey "^[[1;3C" forward-word;
  bindkey "^[[1;3D" backward-word;
} || {
  bindkey "^[[1;9C" forward-word;
  bindkey "^[[1;9D" backward-word;
}
bindkey '^[g'  _autojump_fzf
bindkey '^[v'  vi-cmd-mode
bindkey '^[k' kill-line
bindkey \^U backward-kill-line

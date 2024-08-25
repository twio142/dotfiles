# You can put files here to add functionality separated per file, which
# will be ignored by git.
# Files on the custom/ directory will be automatically loaded by the init
# script, in alphabetical order.

# For example: add yourself some shortcuts to projects you often work on.
#
# brainstormr=~/Projects/development/planetargon/brainstormr
# cd $brainstormr
#

source ~/.local/bin/ssh-completion

alias back='cd "$OLDPWD"'
alias gdv='git difftool -y -t nvimdiff'
alias reconfig='omz reload'
alias vim=nvim
alias btm='btm --theme nord$(test $(~/.local/bin/background) = light && echo -light)'
alias lzg=lazygit

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
ipy() { ${1:-~/.local/bin/py3} -m IPython }
lzd() {
  docker ps &> /dev/null && lazydocker || { echo Docker not running >&2; return 1 }
}

export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_INSECURE_REDIRECT=1
# export HOMEBREW_CASK_OPTS=--require-sha
export HOMEBREW_NO_ENV_HINTS=1
# export HOMEBREW_NO_AUTO_UPDATE=1
export PYTHON3_HOST_PROG=$HOME/.local/bin/py3
export PYTHON_HOST_PROG=$HOME/.local/bin/py2

export DENO_INSTALL="$XDG_CACHE_HOME/deno"
export PATH="$DENO_INSTALL/bin:$PATH"

export PATH="$HOME/Projects/netzwerk/accounting/bin:$PATH"
# . "$HOME/projects/netzwerk/accounting/lib/act_completion"

export PATH="$PATH:$HOME/.local/bin"

export MPLCONFIGDIR="$XDG_CONFIG_HOME"/matplotlib
export LESSHISTFILE="$XDG_STATE_HOME"/less/history
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history
# export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export SQLITE_HISTORY="$XDG_CACHE_HOME"/sqlite_history
export GOPATH=$XDG_DATA_HOME/go
export PATH=$PATH:$GOPATH/bin
export TERMINFO="$XDG_DATA_HOME"/terminfo
export TERMINFO_DIRS="$XDG_DATA_HOME"/terminfo:/usr/share/terminfo

# >>> nvm >>>
export NVM_DIR="$XDG_DATA_HOME"/nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# <<< nvm <<<

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("$HOME/miniconda3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
export PATH="$HOME/miniconda3/bin:$PATH"

### FZF OPTIONS ###

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
[ -z $alfred_version ] && . ${XDG_CONFIG_HOME:-~/.config}/fzf/fzf-git.sh

export FZF_DEFAULT_OPTS='--layout=reverse --cycle --inline-info --color=fg+:-1,bg+:-1,hl:bright-red,hl+:red,pointer:bright-red,info:-1,prompt:-1 --pointer=➤ --bind="ctrl-d:preview-down" --bind="ctrl-u:preview-up"'

# Use `` as the trigger sequence instead of the default **
export FZF_COMPLETION_TRIGGER="\`\`"
# Options to fzf command
export FZF_COMPLETION_OPTS="$FZF_DEFAULT_OPTS"
export FZF_CTRL_R_OPTS="--bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'"
# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".DS_Store" --exclude ".git" . "$1"
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
    cd)           fzf --preview 'tree -C {} -L 4' "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    vim)          fzf --preview "$XDG_CONFIG_HOME/fzf/fzf-preview.sh {}" --bind "ctrl-s:reload(cat $XDG_CACHE_HOME/neomru/file | sed '2,10!d')" "$@" ;;
    chezmoi)      chezmoi managed -p absolute | fzf --preview "$XDG_CONFIG_HOME/fzf/fzf-preview.sh {}" --bind "ctrl-s:reload(chezmoi status -i files -p absolute | choose 1..)+change-preview(chezmoi diff {})" "$@" ;;
    *)            fzf --preview "$XDG_CONFIG_HOME/fzf/fzf-preview.sh {}" "$@" ;;
  esac
}

# >>> autojump >>>
[ -f $(brew --prefix)/etc/profile.d/autojump.sh ] && . $(brew --prefix)/etc/profile.d/autojump.sh
autoload -U compinit && compinit -u
# <<< autojump <<<

_autojump_fzf() {
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

_fzf_image() {
  local query=${LBUFFER##* }
  local selected=$(fd --exclude ".git" -e jpg -e jpeg -e png -e gif -e bmp -e tiff -e webp | fzf -m --query=${query} --preview "$XDG_CONFIG_HOME/fzf/fzf-preview.sh {}" --preview-window='bottom,80%')
  local ret=$?
  if [[ -n $selected ]]; then
    LBUFFER=${LBUFFER% *}
    echo -n $selected | while read -r line; do
      LBUFFER+=\ ${line:q}
    done
  fi
  unset query selected
  zle reset-prompt
  return $ret
}
zle -N _fzf_image

export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="$PATH:$(ruby -e 'puts Gem.bindir')"
source $(dirname $(gem which colorls))/tab_complete.sh
alias ls='colorls --$(~/.local/bin/background) --time-style="+%Y-%m-%d %H:%M"'

auto-color-ls() {
  emulate -L zsh
  echo
  colorls --$(~/.local/bin/background) -A --group-directories-first
}

chpwd_functions=(auto-color-ls $chpwd_functions)

# tmux

ta() {
  if [[ -z $1 || ${1:0:1} == '-' ]]; then
    tmux attach "$@"
  else
    tmux attach -t "$@"
  fi
}

alias tl='tmux list-sessions'

ts() {
  if [[ -z $1 || ${1:0:1} == '-' ]]; then
    tmux new-session "$@"
  else
    tmux new-session -s "$@"
  fi
}

_tmux_copy_mode() { tmux copy-mode }
_tmux_find() { tmux copy-mode \; send-keys "?" }
_tmux_paste() { tmux paste-buffer }
_tmux_paste_escape() { printf "%q" "$(pbpaste)" | tmux load-buffer - \; paste-buffer -d }
_tmux_wk_menu() { tmux show-wk-menu-root }
_tmux_prev_mark() { tmux copy-mode \; send-keys -X search-backward "^❯ " }
_tmux_next_mark() { tmux copy-mode \; send-keys -X search-forward "^❯ " }
_tmux_key_bindings() {
  zle -N _tmux_copy_mode
  zle -N _tmux_find
  zle -N _tmux_paste
  zle -N _tmux_paste_escape
  zle -N _tmux_wk_menu
  zle -N _tmux_prev_mark
  zle -N _tmux_next_mark
  bindkey '^[[' _tmux_copy_mode
  bindkey '^[/' _tmux_find
  bindkey '^[]' _tmux_paste
  bindkey '^Xv' _tmux_paste_escape
  bindkey '^[ ' _tmux_wk_menu
  bindkey '^[[1;3A' _tmux_prev_mark
  bindkey '^[[1;3B' _tmux_next_mark
  bindkey '^[[1;3C' forward-word
  bindkey '^[[1;3D' backward-word
}

bindkey '^[[1;9C' forward-word
bindkey '^[[1;9D' backward-word
bindkey '^[g' _autojump_fzf
bindkey '^[v' vi-cmd-mode
bindkey '^[k' kill-line
bindkey '^U' backward-kill-line
bindkey '^J' down-line-or-select
bindkey -M menuselect '^J' down-history
bindkey -M menuselect '^K' up-history
bindkey '^Xi' _fzf_image

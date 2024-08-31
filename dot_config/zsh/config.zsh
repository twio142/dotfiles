alias back='cd "$OLDPWD"'
alias gdv='git difftool -y -t nvimdiff'
alias reconfig='exec zsh'
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
  local url=$(git "$@" config --get remote.${remote:-origin}.url)
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

export MPLCONFIGDIR="$XDG_CONFIG_HOME"/matplotlib
export LESSHISTFILE="$XDG_STATE_HOME"/less/history
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
export NODE_PATH=$(npm root -g)
export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history
# export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export SQLITE_HISTORY="$XDG_CACHE_HOME"/sqlite_history
export GOPATH=$XDG_DATA_HOME/go
export PATH=$PATH:$GOPATH/bin
export TERMINFO="$XDG_DATA_HOME"/terminfo
export TERMINFO_DIRS="$XDG_DATA_HOME"/terminfo:/usr/share/terminfo

# custom completions
# this must be placed before nvm's bash_completion
[ -d $ZDOTDIR/completions ] && fpath=($ZDOTDIR/completions $fpath)

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

source $XDG_CONFIG_HOME/fzf/fzf-setup.zsh

export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="$PATH:$(ruby -e 'puts Gem.bindir')"
source $(dirname $(gem which colorls))/tab_complete.sh
alias ls='colorls --time-style="+%F %R"'

auto-color-ls() {
  emulate -L zsh
  echo
  colorls -A --group-directories-first
}

chpwd_functions=(auto-color-ls $chpwd_functions)

[ -f $(brew --prefix)/etc/profile.d/autojump.sh ] && source $(brew --prefix)/etc/profile.d/autojump.sh

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/Projects/netzwerk/accounting/bin:$PATH"

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

# restore ↑ and ↓ keys
() {
  local -a prefix=( '\e'{\[,O} )
  local -a up=( ${^prefix}A ) down=( ${^prefix}B )
  local key=
  for key in $up[@]; do
    bindkey "$key" up-line-or-history
  done
  for key in $down[@]; do
    bindkey "$key" down-line-or-history
  done
}

bindkey '^[[1;9C' forward-word
bindkey '^[[1;9D' backward-word
bindkey '^[v' vi-cmd-mode
bindkey '^[k' kill-line
bindkey '^U' backward-kill-line
bindkey '^J' down-line-or-select
bindkey -M menuselect '^J' down-history
bindkey -M menuselect '^K' up-history

[ -n "$TMUX" ] && {
  autoload -Uz add-zsh-hook;
  add-zsh-hook precmd _tmux_key_bindings;
}

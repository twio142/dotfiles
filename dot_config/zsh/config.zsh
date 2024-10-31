alias gdv='git difftool -y'
alias v='nvim'
alias vim='nvim'
alias t='tmux'
alias btm='btm --theme nord$(test $(~/.local/bin/background) = light && echo -light)'
alias ipy='ipython'
alias lzg='lazygit'
alias git_current_branch='git rev-parse --abbrev-ref HEAD'
alias ssh='TERM=xterm-256color ssh'
alias tree='tree -atrC -L 4 -I .DS_Store -I .git -I node_modules -I __pycache__'
alias reconfig='exec zsh'

back() { cd $OLDPWD }
co() { 1="$*"; gh copilot suggest "$1" }
coe() { 1="$*"; gh copilot explain "$1" }
lc() {
  1=${1:a}
  [ -d $1 ] && cd $1 || cd ${1:h};
}
gitup() {
  1=$(git -C "${1:-$PWD}" rev-parse --show-toplevel 2> /dev/null) || { echo "Not a git repository" >&2; return 1; }
  open -b co.gitup.mac $1
}
gro() {
  local url=$(git "$@" config --get remote.${remote:-origin}.url)
  url=$(echo $url | perl -pe 's/.+(git(hub|lab).com)[:\/]([^\/]+\/[^\/]+?)/https:\/\/\1\/\3/g')
  [ -z $url ] || open $url
}
lzd() {
  docker ps &> /dev/null && lazydocker || { echo "Docker not running" >&2; return 1 }
}
timezsh() {
  shell=${1-$SHELL}
  for i in $(seq 1 10); do /usr/bin/time $shell -i -c exit; done
}
z() {
  command -v __zoxide_z &> /dev/null || eval "$(zoxide init zsh)"
  __zoxide_z "$@"
}

export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_INSECURE_REDIRECT=1
# export HOMEBREW_CASK_OPTS=--require-sha
export HOMEBREW_NO_ENV_HINTS=1
# export HOMEBREW_NO_AUTO_UPDATE=1
export PYTHON3_HOST_PROG=$HOME/.local/bin/python3
export PYTHON_HISTORY=$XDG_STATE_HOME/python_history

export DENO_INSTALL="$XDG_CACHE_HOME/deno"
export PATH="$DENO_INSTALL/bin:$PATH"

export MPLCONFIGDIR="$XDG_CONFIG_HOME"/matplotlib
export LESSHISTFILE="$XDG_STATE_HOME"/less/history
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
export NODE_PATH=$XDG_DATA_HOME/npm/lib/node_modules # $(npm root -g)
export NODE_REPL_HISTORY="$XDG_STATE_HOME"/node_repl_history
export PATH="$XDG_DATA_HOME/npm/bin:$PATH"

# export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export SQLITE_HISTORY="$XDG_CACHE_HOME"/sqlite_history
export GOPATH=$XDG_DATA_HOME/go
export PATH=$PATH:$GOPATH/bin
export TERMINFO="$XDG_DATA_HOME"/terminfo
export TERMINFO_DIRS="$XDG_DATA_HOME"/terminfo:/usr/share/terminfo

# custom completions
[ -d $ZDOTDIR/completions ] && fpath=($ZDOTDIR/completions $fpath)
[ -d $ZDOTDIR/functions ] && fpath=($ZDOTDIR/functions $fpath)

# asdf
export ASDF_DATA_DIR="$XDG_DATA_HOME"/asdf
export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME=.config/asdf/tool-versions
. $(brew --prefix asdf)/libexec/asdf.sh

# >>> mamba initialize >>>
export MAMBA_EXE='/opt/homebrew/opt/micromamba/bin/micromamba';
export MAMBA_ROOT_PREFIX="$XDG_DATA_HOME/micromamba";
# __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__mamba_setup"
# else
#     alias micromamba="$MAMBA_EXE"  # Fallback on help from mamba activate
# fi
# unset __mamba_setup
# <<< mamba initialize <<<

# lazyload mamba
lazy_mamba_aliases=('micromamba')

load_mamba() {
  for lazy_mamba_alias in $lazy_mamba_aliases; do
    unalias $lazy_mamba_alias 2> /dev/null
  done
  # >>> mamba initialize >>>
  __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
  if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
  else
    alias micromamba="$MAMBA_EXE"  # Fallback on help from mamba activate
  fi
  unset __mamba_setup
  # <<< mamba initialize <<<
  unset __mamba_prefix
  # unfunction load_mamba
}

for lazy_mamba_alias in $lazy_mamba_aliases; do
  alias $lazy_mamba_alias="load_mamba && $lazy_mamba_alias"
done
alias mamba="load_mamba && micromamba"

euporie_aliases=('euporie' 'euporie-console' 'euporie-hub' 'euporie-notebook' 'euporie-preview')
for euporie_alias in $euporie_aliases; do
  alias $euporie_alias=$euporie_alias' --color-scheme=$(~/.local/bin/background) --syntax-theme=gruvbox-$(~/.local/bin/background)'
done

source $XDG_CONFIG_HOME/fzf/fzf-setup.zsh

export LS_COLORS="$(vivid generate one-light)"
alias ls='lsd'
auto-ls() {
  emulate -L zsh
  echo
  ls
}
chpwd_functions=(auto-ls $chpwd_functions)

export PATH="$HOME/.local/bin:$PATH"

# tmux

ta() {
  if [[ -z $1 || ${1:0:1} == '-' ]]; then
    tmux attach "$@"
  else
    tmux attach -t "$@"
  fi
}

alias tl='tmux ls'

tn() {
  if [[ -z $1 || ${1:0:1} == '-' ]]; then
    tmux new "$@"
  else
    tmux new -s "$@"
  fi
}

_tmux_copy_mode() { tmux copy-mode }
_tmux_find() { tmux copy-mode \; send "?" }
_tmux_paste() { tmux pasteb }
_tmux_wk_menu() { tmux show-wk-menu-root }
_tmux_prev_mark() { tmux copy-mode \; send -X search-backward "^❯ " }
_tmux_next_mark() { tmux copy-mode \; send -X search-forward "^❯ " }
_tmux_key_bindings() {
  zle -N _tmux_copy_mode
  zle -N _tmux_find
  zle -N _tmux_paste
  zle -N _tmux_wk_menu
  zle -N _tmux_prev_mark
  zle -N _tmux_next_mark
  bindkey '^[[' _tmux_copy_mode
  bindkey '^[v' _tmux_copy_mode
  bindkey '^[/' _tmux_find
  bindkey '^[]' _tmux_paste
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

paste_escape() {
  local escaped=$(printf '%q' "$(pbpaste)")
  BUFFER+="$escaped"
  CURSOR=${#BUFFER}
}
zle -N paste_escape

_back() { [ "$OLDPWD" = "$PWD" ] || { cd $OLDPWD; zle accept-line } }
zle -N _back
bindkey '^[,' _back
bindkey ' ' magic-space

bindkey '^[b' backward-word
bindkey '^[f' forward-word
bindkey '^[e' edit-command-line
bindkey '^[d' kill-word
bindkey '^[h' run-help
bindkey '^[k' kill-line
bindkey '^[x' execute-named-cmd

bindkey '^[[1;9C' forward-word
bindkey '^[[1;9D' backward-word
bindkey '^U' backward-kill-line
bindkey -M vicmd '^U' backward-kill-line
bindkey -M vicmd '^W' backward-kill-word
# bindkey '^V' vi-cmd-mode

bindkey '^N' down-line-or-select
bindkey '^J' down-line-or-select
bindkey -M menuselect '^J' down-history
bindkey -M menuselect 'j' down-history
bindkey -M menuselect '^K' up-history

bindkey '^Xa' _expand_alias
bindkey '^Xu' undo
bindkey '^Xv' paste_escape
bindkey '^X/' recent-paths

[ -n "$TMUX" ] && {
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _tmux_key_bindings
  zvm_after_lazy_keybindings_commands+=(_tmux_key_bindings)
}

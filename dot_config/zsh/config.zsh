alias gdv='git difftool -y'
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias t='tmux'
alias ipy='ipython'
alias lzg='lazygit'
alias leet='nvim leetcode'
alias tree='tree -atrC -L 4 -I .DS_Store -I .git -I node_modules -I __pycache__'
alias reconfig='exec zsh'
alias gping='gping --vertical-margin "$((($(tput lines) - 20) / 2))" --clear'
alias cm=chezmoi

back() { cd $OLDPWD }
co() { 1="$*"; gh copilot suggest "$1" }
coe() { 1="$*"; gh copilot explain "$1" }
lc() {
  1=${1:a}
  [ -d $1 ] && cd $1 || cd ${1:h};
}
gro() {
  local url=$(git "$@" config --get remote.${remote:-origin}.url)
  url=$(echo $url | perl -pe 's/.+(git(hub|lab).com)[:\/]([^\/]+\/[^\/]+?)/https:\/\/\1\/\3/g')
  [ -z $url ] || open $url
}
git_current_branch() {
  git rev-parse --abbrev-ref HEAD
}
lzd() {
  docker ps &> /dev/null && lazydocker || { echo "Docker not running" >&2; return 1 }
}
timesh() {
  shell=${1-$SHELL}
  for i in $(seq 1 10); do /usr/bin/time $shell -i -c exit; done
}
docker() {
  case "$1" in
    version|help) /usr/local/bin/docker "$@" ;;
    quit|q) /usr/local/bin/orbctl stop docker; pkill -x OrbStack\ Helper ;;
    *) docker version &> /dev/null || /usr/local/bin/orbctl start docker; /usr/local/bin/docker "$@" ;;
  esac
}

export PATH="/opt/homebrew/opt/curl/bin:$PATH"
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_INSECURE_REDIRECT=1
# export HOMEBREW_CASK_OPTS=--require-sha
export HOMEBREW_NO_ENV_HINTS=1
# export HOMEBREW_NO_AUTO_UPDATE=1
export PYTHON3_HOST_PROG=/usr/local/bin/python3
export PYTHON_HISTORY=$XDG_STATE_HOME/python_history

export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export DENO_INSTALL="$XDG_CACHE_HOME"/deno
export PATH="$DENO_INSTALL/bin:$PATH"

export MPLCONFIGDIR="$XDG_CONFIG_HOME"/matplotlib
export LESSHISTFILE="$XDG_STATE_HOME"/less/history
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
export NODE_PATH="$XDG_DATA_HOME"/npm/lib/node_modules # $(npm root -g)
export NODE_REPL_HISTORY="$XDG_STATE_HOME"/node_repl_history
export PATH="$XDG_DATA_HOME/npm/bin:$PATH"

export SQLITE_HISTORY="$XDG_CACHE_HOME"/sqlite_history
export GOPATH=$XDG_DATA_HOME/go
export PATH=$PATH:$GOPATH/bin
export TERMINFO="$XDG_DATA_HOME"/terminfo
export TERMINFO_DIRS="$XDG_DATA_HOME"/terminfo:/usr/share/terminfo

export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME"/ripgrep/ripgreprc

# custom completions
[ -d $ZDOTDIR/completions ] && fpath=($ZDOTDIR/completions $fpath)
[ -d $ZDOTDIR/functions ] && fpath=($ZDOTDIR/functions $fpath)

# asdf
export ASDF_DATA_DIR="$XDG_DATA_HOME"/asdf
export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME=.config/asdf/tool-versions
export PATH="${ASDF_DATA_DIR}/shims:$PATH"
[ -d ${ASDF_DATA_DIR}/completions ] && fpath=(${ASDF_DATA_DIR}/completions $fpath)

# >>> mamba initialize >>>
export MAMBA_EXE='/opt/homebrew/opt/micromamba/bin/mamba';
export MAMBA_ROOT_PREFIX="$XDG_DATA_HOME/micromamba";
mamba() {
  {
    __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
    eval "$__mamba_setup" 2> /dev/null
    unset __mamba_setup
  } > /dev/null 2>&1
  __mamba_wrap "$@"
}
# <<< mamba initialize <<<

# custom p10k segments
function prompt_yazi_level() {
  [ -z $YAZI_LEVEL ] || p10k segment -i 󰇥 -f yellow -t "$YAZI_LEVEL"
}

function prompt_alfred_workflow() {
  [ -z $alfred_workflow_name ] || p10k segment -i 󰮤 -f '#9F55EB' -t "$alfred_workflow_name"
}

source $XDG_CONFIG_HOME/fzf/fzf-setup.zsh

eval "$(zoxide init zsh)"

alias ls='lsd'
auto-ls() {
  emulate -L zsh
  echo
  ls
}
chpwd_functions=(auto-ls $chpwd_functions)

export PATH="$HOME/.local/bin:$PATH"

WORDCHARS=${WORDCHARS//[\/]}

# vi mode

function zle-keymap-select {
  case $KEYMAP in
    vicmd|visual) echo -ne '\e[1 q' ;;
    # viopp) echo -ne '\e[3 q' ;;
    *)     echo -ne '\e[5 q' ;;
  esac
}

function zle-line-init {
  zle-keymap-select
}

zle -N zle-keymap-select
zle -N zle-line-init

for m in vicmd visual viopp; do
  bindkey -M $m H vi-first-non-blank
  bindkey -M $m L end-of-line
done

autoload -U select-quoted
zle -N select-quoted
autoload -U select-bracketed
zle -N select-bracketed

for m in visual viopp; do
  for c in {a,i}{\',\",\`}; do
    bindkey -M $m $c select-quoted
  done
  for c in {a,i}{\[,\],\{\},\(,\)}; do
    bindkey -M $m $c select-bracketed
  done
done

autoload -Uz surround
zle -N delete-surround surround
zle -N add-surround surround
zle -N change-surround surround

bindkey -a 'ds' delete-surround
bindkey -a 'cs' change-surround
bindkey -a 'S' add-surround

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
_tmux_paste() {
  BUFFER+=$(tmux show-buffer)
  CURSOR=${#BUFFER}
}
_tmux_wk_menu() { tmux show-wk-menu-root }
_tmux_prev_mark() { tmux copy-mode \; send -X search-backward "^❯ " \; send -X search-again }
_tmux_next_mark() { tmux copy-mode \; send -X search-forward "^❯ " }
_tmux_key_bindings() {
  zle -N _tmux_copy_mode
  zle -N _tmux_find
  zle -N _tmux_paste
  zle -N _tmux_wk_menu
  zle -N _tmux_prev_mark
  zle -N _tmux_next_mark
  bindkey '^[[' _tmux_copy_mode
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

bindkey '^B' backward-word
bindkey '^F' forward-word
bindkey '^[e' edit-command-line
bindkey '^[d' kill-word
bindkey '^[h' run-help
bindkey '^[k' kill-line
bindkey '^[x' execute-named-cmd
bindkey '^[v' vi-cmd-mode

bindkey '^[[1;9C' forward-word
bindkey '^[[1;9D' backward-word
bindkey '^U' backward-kill-line
bindkey -M vicmd '^U' backward-kill-line
bindkey -M vicmd '^W' backward-kill-word
bindkey jh vi-cmd-mode

bindkey '^N' down-line-or-select
bindkey '^J' down-line-or-select
bindkey -M menuselect '^J' down-history
bindkey -M menuselect 'j' down-history
bindkey -M menuselect '^K' up-history

bindkey '^Xa' _expand_alias
bindkey '^Xu' undo
bindkey '^Xv' paste_escape
bindkey '^X/' recent-paths

[ -n "$TMUX" ] && _tmux_key_bindings

if [ -z $alfred_version ]; then
  if [ -z $NON_FIRST_SHELL ]; then
    t=$(echo "evening morning afternoon" | awk -v h="$(gdate +%H)" '{ print (h < 3 || h > 18) ? $1 : (h < 12) ? $2 : $3 }')
    echo -e "\e[38;5;57m\e[1mGood $t, Shin ฅ^•ﻌ•^ฅ\e[0m"
    unset t
    export NON_FIRST_SHELL=1
    [ -z $TMUX ] || tmux set-environment NON_FIRST_SHELL 1
  fi
  if [[ -n "$TMUX" && -s "/var/mail/$USER" ]]; then
    echo "  You have mail."
  fi
fi

[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)" || true

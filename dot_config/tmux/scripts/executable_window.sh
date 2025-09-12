#!/bin/zsh

# Tmux window title processor
# Generates dynamic window titles based on command, directory, or git branch

if [[ "$SET" = -g || "$SET" = -w ]]; then
  case "$1" in
    dir|branch) ;;
    *) 1=cmd ;;
  esac
  if [[ "$SET" = -w ]] && tmux show -w automatic-rename-format | grep -q "$1"; then
    tmux set -u automatic-rename-format
  else
    tmux set $SET automatic-rename-format "#{?pane_in_mode, ,#{pane_current_command} '#{pane_current_path}' $1}#{?pane_dead, 󱈸,}"
  fi
  exit 0
fi

cmd=$1
dir=$2
pattern=${3:-cmd}

# Function to get command icon/name
get_command_title() {
  case "$1" in
    alfred|alfred-cli)         echo "󰮤 " ;;
    bash)                      echo " " ;;
    btop)                      echo "󰓅 " ;;
    curl|curlie)               echo " " ;;
    deno)                      echo " " ;;
    docker|lazydocker)         echo " " ;;
    git|lazygit)               echo "󰊢 " ;;
    gh)                        echo " " ;;
    go)                        echo " " ;;
    lldb)                      echo " " ;;
    lua)                       echo "󰢱 " ;;
    node)                      echo " " ;;
    nvim)                      echo " " ;;
    [Pp]ython*|conda|mamba|uv) echo " " ;;
    ruby)                      echo "󰴭 " ;;
    scli)                      echo "󰀘 " ;;
    ssh)                       echo "󰢹 " ;;
    sqlite3|lazysql)           echo " " ;;
    sudo)                      echo " " ;;
    swift*)                    echo "󰛥 " ;;
    tmux)                      echo " " ;;
    vim)                       echo " " ;;
    ya|yazi)                   echo "󰇥 " ;;
    zsh)                       echo " " ;;
    *)                         echo "$1" ;;
  esac
}

# Function to get git branch or fallback to path
scpt="${0:A:h}/git.sh"
get_branch_title() {
  local ref=$("$scpt" $1 1)
  if [ -n "$ref" ]; then
    echo "${ref:2:-1}"
  else
    echo "${1:t}"
  fi
}

# Generate title based on pattern
case "$pattern" in
  dir)
    echo "${dir:t}" ;;
  branch)
    get_branch_title "$dir" ;;
  *)
    # Default to command pattern
    get_command_title "$cmd" ;;
esac

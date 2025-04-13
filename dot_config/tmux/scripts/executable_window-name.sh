#!/bin/zsh

case "$1" in
  bash|zsh) echo " " ;;
  deno)     echo " " ;;
  docker|lazydocker)
            echo "󰡨 " ;;
  git|lazygit)
            echo "󰊢 " ;;
  go)       echo " " ;;
  lldb|swift*)
            echo "󰛥 " ;;
  lua)      echo "󰢱 " ;;
  node)     echo " " ;;
  nvim)     echo " " ;;
  python*)  echo " " ;;
  ruby)     echo " " ;;
  ssh)      echo " " ;;
  sqlite3|lazysql)
            echo " " ;;
  tmux)     echo " " ;;
  '[tmux]') echo " " ;;
  vim)      echo " " ;;
  ya|yazi)  echo "󰇥 " ;;
  *)        echo $1 ;;
esac

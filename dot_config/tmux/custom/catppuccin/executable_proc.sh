#!/bin/zsh

case "$1" in
  bash)     echo " " ;;
  btop)     echo "󰓅 " ;;
  curl|curlie)
            echo " " ;;
  deno)     echo " " ;;
  docker|lazydocker)
            echo " " ;;
  git|lazygit)
            echo "󰊢 " ;;
  gh)       echo " " ;;
  go)       echo " " ;;
  lldb)     echo " " ;;
  lua)      echo "󰢱 " ;;
  node)     echo " " ;;
  nvim)     echo " " ;;
  [Pp]ython*|conda|mamba|uv)
            echo " " ;;
  ruby)     echo "󰴭 " ;;
  scli)     echo "󰀘 " ;;
  ssh)      echo "󰢹 " ;;
  sqlite3|lazysql)
            echo " " ;;
  sudo)     echo " " ;;
  swift*)   echo "󰛥 " ;;
  tmux)     echo " " ;;
  '[tmux]') echo " " ;;
  vim)      echo " " ;;
  ya|yazi)  echo "󰇥 " ;;
  zsh)      echo " " ;;
  *)        echo $1 ;;
esac

#!/bin/zsh

case "$1" in
  bash)     echo " " ;;
  btop)     echo "󰓅 " ;;
  curl)     echo " " ;;
  deno)     echo " " ;;
  docker|lazydocker)
            echo " " ;;
  git|lazygit)
            echo "󰊢 " ;;
  gh)       echo " " ;;
  go)       echo " " ;;
  lldb)     echo " " ;;
  lua)      echo "󰢱 " ;;
  node)     echo " " ;;
  nvim)     echo " " ;;
  python*|conda|mamba)
            echo " " ;;
  ruby)     echo " " ;;
  ssh)      echo " " ;;
  sqlite3|lazysql)
            echo " " ;;
  swift*)   echo "󰛥 " ;;
  tmux)     echo " " ;;
  '[tmux]') echo " " ;;
  vim)      echo " " ;;
  ya|yazi)  echo "󰇥 " ;;
  zsh)      echo " " ;;
  *)        echo $1 ;;
esac

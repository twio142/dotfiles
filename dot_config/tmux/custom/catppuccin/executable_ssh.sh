#!/bin/sh

show_ssh() {
  local index color module

  index=$1
  color=$thm_magenta
  icon=

  if [ "$status_fill" = "icon" ]; then
    local bg
    local icon_prefix="#[fg=$thm_bg,bg=$color,nobold,nounderscore,noitalics]"
    local text_prefix="#[fg=$thm_fg,bg=$thm_gray] "

    if [ "$status_connect_separator" = "yes" ]; then
      bg="$thm_gray"
    else
      bg="default"
    fi

    local left_separator="#[fg=$color,bg=$bg,nobold,nounderscore,noitalics]$status_left_separator"
    local middle_separator="#[fg=$color,bg=$thm_gray,nobold,nounderscore,noitalics]$status_middle_separator"
    local right_separator="#[fg=$thm_gray,bg=$bg,nobold,nounderscore,noitalics]$status_right_separator"
  fi

  if [ "$status_fill" = "all" ]; then
    local icon_prefix="#[fg=$thm_bg,bg=$color,nobold,nounderscore,noitalics]"
    local text_prefix="#[fg=$thm_bg,bg=$color]"

    if [ "$status_connect_separator" = "yes" ]; then
      local left_separator="#[fg=$color,nobold,nounderscore,noitalics]$status_left_separator"
      local right_separator="#[fg=$color,bg=$color,nobold,nounderscore,noitalics]$status_right_separator"

    else
      local left_separator="#[fg=$color,bg=default,nobold,nounderscore,noitalics]$status_left_separator"
      local right_separator="#[fg=$color,bg=default,nobold,nounderscore,noitalics]$status_right_separator"
    fi

  fi

  if [ $((index)) -eq 0 ]; then
    local left_separator="#[fg=$color,bg=default,nobold,nounderscore,noitalics]$status_left_separator"
  fi

  text_prefix="$left_separator$icon_prefix$icon $middle_separator$text_prefix"
  module="#( ${BASH_SOURCE[0]} \"#{@ssh_connection}\" \"#{client_width}\" \"$text_prefix\" \"$right_separator\" )"
  echo "$module"
}

get_ssh() {
  [ -z "$1" ] && return 0

  local client_width=$2
  local text_prefix=$3
  local right_separator=$4
  local text=' '

  if [ "$client_width" -gt 80 ]; then
    text="$USER@$HOSTNAME "
  fi

  echo "$text_prefix$text$right_separator"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && get_ssh "$@" || true

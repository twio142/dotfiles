#!/bin/bash

show_dir() {
  local index color module

  index=$1
  color=$thm_pink
  icon=

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

  text_prefix="$left_separator$icon_prefix$icon$middle_separator$text_prefix"
  module="#( ${BASH_SOURCE[0]} \"#{pane_current_path}\" \"#{client_width}\" \"$text_prefix\" \"$right_separator\" )"
  echo "$module"
}

get_dir() {
  [ -z "$1" ] && return 0

  [[ $1 == "/" ]] && {
    echo "$3 /$4 "
    return 0
  }

  local dir="${1/#$HOME/~}"
  local parts
  IFS='/' read -ra parts <<< "$dir"
  local result=""
  local base="${parts[${#parts[@]}-1]}"

  local max=$(( $2 / 4 - ${#base} ))
  local min=$(( $2 / 8 - ${#base} ))
  if [[ "${#dir}" -gt 1 ]]; then
    for ((i=0; i<${#parts[@]}-1; i++)); do
      if [[ ${#result} -gt $max ]]; then
        result=""
        break
      fi
      if [[ $i -eq ${#parts[@]}-2 && ${#result} -le ${min}-${#parts[$i]} ]]; then
        result="${result}${parts[$i]}/"
        continue
      fi
      part="${parts[$i]:0:1}"
      if [[ $part =~ [\._] ]]; then
        part="${parts[$i]:0:2}"
      fi
      result="${result}${part}/"
    done
  fi

  echo "$3 #[dim]${result}#[none]#[bold]${base}$4 "
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && get_dir "$@" || true


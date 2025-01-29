#!/bin/sh

show_git() {
  local index color module

  index=$1
  color=$thm_blue

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

  module="#( ${BASH_SOURCE[0]} \"#{pane_current_path}\" \"#{client_width}\" \"$left_separator\" \"$icon_prefix\" \"$middle_separator\" \"$text_prefix\" \"$right_separator\" )"
  echo "$module"
}

get_git_status() {
  local icon head staged dirty new ahead behind sep stash
  local cwd=$1
  local client_width=$2
  local left_separator=$3
  local icon_prefix=$4
  local middle_separator=$5
  local text_prefix=$6
  local right_separator=$7
  local text

  icon=
  head=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2> /dev/null) || return 0;
  if [ "$head" = HEAD ]; then
    { icon= ; head=$(git -C "$cwd" describe --tags --exact-match 2> /dev/null); } ||
    { icon= ; head=$(git -C "$cwd" rev-parse --short HEAD); }
  fi
  if [ "$client_width" -le 80 ]; then
    text="$head "
  else
    staged=$(git -C "$cwd" diff --staged --name-only | wc -l)
    [ "$staged" -gt 0 ] && staged=" +${staged// }" || staged=''
    dirty=$(git -C "$cwd" diff --name-only | wc -l)
    [ "$dirty" -gt 0 ] && dirty=" !${dirty// }" || dirty=''
    new=$(git -C "$cwd" ls-files --others --exclude-standard | wc -l)
    [ "$new" -gt 0 ] && new=" ?${new// }" || new=''
    ahead=$(git -C "$cwd" rev-list --count HEAD "^$(git -C "$cwd" for-each-ref --format '%(upstream:short)' $(git -C "$cwd" symbolic-ref -q HEAD))" 2> /dev/null)
    behind=$(git -C "$cwd" rev-list --count $(git -C "$cwd" for-each-ref --format '%(upstream:short)' $(git -C "$cwd" symbolic-ref -q HEAD)) ^HEAD 2> /dev/null)
    [ "$ahead" -gt 0 ] && ahead="󱦲$ahead" || ahead=''
    [ "$behind" -gt 0 ] && behind="󱦳$behind" || behind=''
    [ -n "$ahead$behind" ] && sep=" " || sep=''
    stash=$(git -C "$cwd" stash list | wc -l)
    [ "$stash" -gt 0 ] && stash=" *${stash// }" || stash=''
    text="$head$staged$sep$behind$ahead$dirty$new$stash "
  fi

  echo "$left_separator$icon_prefix$icon $middle_separator$text_prefix$text$right_separator"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && get_git_status "$@" || true

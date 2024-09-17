#!/bin/sh

show_git() {
  local index icon color text module
  local s=${BASH_SOURCE[0]}
  local p="\"#{pane_current_path}\""

  index=$1
  icon="$( get_tmux_option "@catppuccin_git_icon" "#($s $p icon)" )"
  color="$( get_tmux_option "@catppuccin_git_color" "#($s $p color '$thm_blue')" )"
  text="$( get_tmux_option "@catppuccin_git_text" "#($s $p text #{client_width})" )"

  module=$( build_status_module "$index" "$icon" "$color" "$text" )
  echo "$module"
}

get_git_status() {
  local icon head staged dirty new ahead behind sep stash
  icon=
  head=$(git -C "$1" rev-parse --abbrev-ref HEAD 2> /dev/null) || return 0;
  [ "$2" = color ] && { printf $3; return 0; }
  if [ "$head" = HEAD ]; then
    { icon=; head=$(git -C "$1" describe --tags --exact-match 2> /dev/null); } ||
    { icon=; head=$(git -C "$1" rev-parse --short HEAD); }
  fi
  [ "$2" = icon ] && { printf "$icon"; return 0; }
  [[ "$2" = text && "$3" -le 80 ]] && { printf "$head "; return 0; }
  staged=$(git -C "$1" diff --staged --name-only | wc -l)
  [ "$staged" -gt 0 ] && staged=" +${staged// }" || staged=''
  dirty=$(git -C "$1" diff --name-only | wc -l)
  [ "$dirty" -gt 0 ] && dirty=" ✷${dirty// }" || dirty=''
  new=$(git -C "$1" ls-files --others --exclude-standard | wc -l)
  [ "$new" -gt 0 ] && new=" ?${new// }" || new=''
  ahead=$(git -C "$1" rev-list --count HEAD "^$(git -C "$1" for-each-ref --format '%(upstream:short)' $(git -C "$1" symbolic-ref -q HEAD))" 2> /dev/null)
  behind=$(git -C "$1" rev-list --count $(git -C "$1" for-each-ref --format '%(upstream:short)' $(git -C "$1" symbolic-ref -q HEAD)) ^HEAD 2> /dev/null)
  [ "$ahead" -gt 0 ] && ahead="󱦲$ahead" || ahead=''
  [ "$behind" -gt 0 ] && behind="󱦳$behind" || behind=''
  [ -n "$ahead$behind" ] && sep=" " || sep=''
  stash=$(git -C "$1" stash list | wc -l)
  [ "$stash" -gt 0 ] && stash=" *${stash// }" || stash=''
  printf "$head$staged$dirty$new$sep$ahead$behind$stash "
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && get_git_status "$@" || true

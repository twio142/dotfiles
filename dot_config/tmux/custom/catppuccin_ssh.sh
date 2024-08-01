# If this module depends on an external Tmux plugin, say so in a comment.
# E.g.: Requires https://github.com/aaronpowell/tmux-weather

show_ssh() { # This function name must match the module name!
  local index icon color text module

  index=$1 # This variable is used internally by the module loader in order to know the position of this module
  icon="$( get_tmux_option "@catppuccin_ssh_icon"  "#{?@ssh_connection, ,}" )"
  color="$( get_tmux_option "@catppuccin_ssh_color" "#{?@ssh_connection,$thm_magenta,}" )"
  text="$( get_tmux_option "@catppuccin_ssh_text"  "#{@ssh_connection}" )"

  if [ -n $text ]; then
    module=$( build_status_module "$index" "$icon" "$color" "" )
    echo "$module"
  fi
}


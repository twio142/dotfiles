show_git() {
  local index icon color text module
  local s=$XDG_CONFIG_HOME/tmux/scripts/git_status.sh
  local p="\"#{pane_current_path}\""

  index=$1
  text="$( get_tmux_option "@catppuccin_git_text" "#($s $p #{client_width})" )"
  icon="$( get_tmux_option "@catppuccin_git_icon" "#($s $p icon || echo)" )"
  color="$( get_tmux_option "@catppuccin_git_color" "#($s $p color && echo \"$thm_blue\" || echo)" )"

  module=$( build_status_module "$index" "$icon" "$color" "$text" )
  echo "$module"
}

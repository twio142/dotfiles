show_git() {
  local index icon color text module

  index=$1
  text="$( get_tmux_option "@catppuccin_git_text" "#(~/.config/tmux/scripts/git_status.sh \"#{pane_current_path}\" #{client_width})" )"
  icon="$( get_tmux_option "@catppuccin_git_icon" "#(git -C \"#{pane_current_path}\" rev-parse --abbrev-ref HEAD && echo  || echo '')" )"
  color="$( get_tmux_option "@catppuccin_git_color" "#(git -C \"#{pane_current_path}\" rev-parse --abbrev-ref HEAD && echo \"$thm_blue\" || echo '')" )"

  module=$( build_status_module "$index" "$icon" "$color" "$text" )
  echo "$module"
}

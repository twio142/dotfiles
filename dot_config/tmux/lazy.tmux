#### Plugins ####
# tmux-resurrect
set -g @resurrect-strategy-nvim 'session'
set -g @resurrect-strategy-vim 'session'
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-save 'C-ß'
set -g @resurrect-restore 'C-®'

# tmux-fzf
FZF_DEFAULT_OPTS_FILE="$XDG_CONFIG_HOME/fzf/fzfrc"
TMUX_FZF_LAUNCH_KEY="C-§"
TMUX_FZF_OPTIONS="-p -w 90% -h 70% -m --preview-window=up,70%"
TMUX_FZF_ORDER="session|window|pane|buffer"
TMUX_FZF_PANE_FORMAT="#{?pane_active,●,-} #{pane_current_command}#{?pane_marked,\t󰃀,}\t #{b:pane_current_path} "
TMUX_FZF_WINDOW_FORMAT="#{?window_active,●,-} #{?#{==:#W,#{pane_current_command}},#W,#W (#{pane_current_command})}\t #{window_panes}#{?window_marked_flag,  󰃀,}   #{b:pane_current_path} "
TMUX_FZF_SESSION_FORMAT="#{?session_attached,󰍹 #{session_attached},-}  #{session_windows}   #{b:session_path} "
TMUX_FZF_MENU=\
"edit config\ntmux edit-config\n"\
"alfred\ntmux alfred\n"\
"memo\ntmux memo\n"\
"tmux manual\ntmux man tmux\n"\
"btop\ntmux btop\n"\
"yazi\ntmux yazi\n"\
"lazygit\ntmux lazygit\n"\
"lazydocker\ntmux lazydocker\n"\
"confetty\ntmux neww timeout 3s $XDG_DATA_HOME/go/bin/confetty\n"\
"toggle status\ntmux toggle-status\n"\
"toggle mouse\ntmux toggle-mouse\n"\
"toggle clipboard\ntmux toggle-clipboard\n"

# catppuccin
set -gF @catppuccin_flavor "#{?@DARK,mocha,latte}"
# latte, frappe, macchiato or mocha

set -g @catppuccin_window_default_text "#($XDG_CONFIG_HOME/tmux/scripts/window.sh #W)"
set -g @catppuccin_window_default_fill "none"
set -g @catppuccin_window_current_text "#[fg=#{thm_orange}]#($XDG_CONFIG_HOME/tmux/scripts/window.sh #W)#[fg=default]"
set -g @catppuccin_window_current_background "#{thm_bg}"
set -g @catppuccin_window_status icon
set -g @catppuccin_icon_window_activity 󰏤
set -g @catppuccin_icon_window_bell 󰂞
set -g @catppuccin_icon_window_last 
set -g @catppuccin_icon_window_current null
set -g @catppuccin_icon_window_zoom 
#             █
set -g @catppuccin_window_right_separator 
set -g @catppuccin_window_middle_separator " "
set -g @catppuccin_window_current_middle_separator " █"
set -g @catppuccin_window_number_position right
set -g @catppuccin_status_background default
set -g @catppuccin_status_modules_right "dir git ssh"
set -g @catppuccin_status_modules_left session
set -g @catppuccin_status_fill all
set -g @catppuccin_status_left_separator 
set -g @catppuccin_status_right_separator null
set -g @catppuccin_status_connect_separator yes
set -g @catppuccin_session_text "#S "
set -g @catppuccin_custom_plugin_dir "$XDG_CONFIG_HOME/tmux/custom/catppuccin"
set -g @catppuccin_menu_style "bg=default"
set -g @catppuccin_menu_selected_style "fg=#{thm_bg},bg=#{thm_magenta}"
setw -g mode-style "fg=#{?@DARK,#cdd6f4,#4c4f69},bg=#{?@DARK,#282099,#c6dcfb}"

# extrakto
set -g @extrakto_fzf_header "f c o g"
set -g @extrakto_key 'ctrl-#'
set -g @extrakto_clip_tool 'tmux load-buffer -'
set -g @extrakto_copy_key 'ctrl-y'
set -g @extrakto_insert_key 'enter'
set -g @extrakto_split_size '20'
# set -g @extrakto_popup_position '0,100'
set -g @extrakto_popup_size '90%,70%'
set -g @extrakto_fzf_unset_default_opts "false"
set -g @extrakto_fzf_layout "reverse"
set -g @extrakto_editor "nvim"
set -g @extrakto_filter_order "word line-trim url all"

# tmux-fingers
set -gF @fingers-backdrop-style "fg=#{?@DARK,black,white},bright"

run "$XDG_CONFIG_HOME/tmux/plugins/tpm/tpm" &
# prefix I   install
# prefix U   update
# prefix M-u remove

unbind C-b
set -g prefix C-Space
bind C-Space send-prefix
unbind "\~"

unbind :
bind : command-prompt -p "❯" -T command

# pass the next key through
bind -n M-= command-prompt -k -p '' 'send "%%"'

# windows
unbind n
bind n if -F "#{>:#{session_windows},1}" next "neww -c '$HOME'"
unbind c
bind c neww -c "$HOME"

# split panes
unbind '"'
bind - splitw -v -l 35% -c "#{pane_current_path}"
unbind %
bind | splitw -h -c "#{pane_current_path}"
bind -n C-| run-shell " \
if [ $(( \$(tmux display -p '8*#{pane_width}-20*#{pane_height}') )) -lt 0 ]; then \
  tmux splitw -v -l 35% -c '#{pane_current_path}'; \
else \
  tmux splitw -h -c '#{pane_current_path}'; \
fi"

# switch panes
bind h selectp -L
bind j selectp -D
bind k selectp -U
bind l selectp -R
bind -n C-h if -F "#{==:#{pane_current_command},nvim}" { send C-h } {
  if -F "#{pane_at_left}#{window_zoomed_flag}" "send C-h" "selectp -L"
}
bind -n C-j if -F "#{==:#{pane_current_command},nvim}" { send C-j } {
  if -F "#{pane_at_bottom}#{window_zoomed_flag}" "send C-j" "selectp -D"
}
bind -n C-k if -F "#{==:#{pane_current_command},nvim}" { send C-k } {
  if -F "#{pane_at_top}#{window_zoomed_flag}" "send C-k" "selectp -U"
}
bind -n C-l if -F "#{==:#{pane_current_command},nvim}" { send C-l } {
  if -F "#{pane_at_right}#{window_zoomed_flag}" "send C-l" "selectp -R"
}
bind H swapp -t "{left-of}"
bind J swapp -D
bind K swapp -U
unbind L
bind L swapp -t "{right-of}"

# resize panes
bind -r C-Left resizep -L 8
bind -r C-Down resizep -D 8
bind -r C-Up resizep -U 8
bind -r C-Right resizep -R 8

# set -g default-terminal "screen-256color" # set terminal to 256 colors
set -g display-time 2000 # 2 seconds for display-time
set -g mouse on # enable mouse support
set -g renumber-windows on # renumber windows when a window is closed
set -g pane-base-index 1 # start pane numbering at 1
# setw -g automatic-rename off # disable auto-rename
# setw -g allow-rename off # disable rename
set -g set-titles on
set -g set-titles-string "#{pane_current_command} ▸ #{b:pane_current_path}" # set title format
set -g escape-time 0 # faster key response
set -g status-justify left # left justify status bar
setw -g monitor-activity off # monitor for activity
setw -g monitor-bell on # monitor for bell
set -g visual-activity on
set -g visual-bell off
set -g menu-border-line "rounded"
set -g popup-border-style "dim"
set -g popup-border-line "rounded"
setw -g window-status-bell-style default
setw -g window-status-activity-style default

# copy mode
setw -g mode-keys vi # vi key bindings in copy mode
bind -n M-v copy-mode
bind -T copy-mode-vi v send -X begin-selection # start selection with v
bind -T copy-mode-vi y send -X copy-selection # copy selection with y
bind -T copy-mode-vi Y send -X copy-end-of-line-and-cancel
bind -T copy-mode-vi Enter send -X copy-selection-and-cancel \; paste-buffer # paste selection
bind -T copy-mode-vi M-Y send -X copy-pipe "pbcopy"
bind -T copy-mode-vi H send -X back-to-indentation
bind -T copy-mode-vi L send -X end-of-line
bind -T copy-mode-vi O send -X copy-pipe-and-cancel "xargs -I _ open '_'"
bind -T copy-mode-vi M-Up send -X previous-prompt
bind -T copy-mode-vi M-Down send -X next-prompt
bind -T copy-mode-vi C-h selectp -L
bind -T copy-mode-vi C-j selectp -D
bind -T copy-mode-vi C-k selectp -U
bind -T copy-mode-vi C-l selectp -R
bind -T copy-mode-vi m send -X set-mark
bind -T copy-mode-vi ` send -X jump-to-mark
bind -T copy-mode-vi r run -b "#{@fingers-cli} start #{pane_id}"
bind -T copy-mode-vi s run -b "#{@fingers-cli} start #{pane_id} --mode jump"
bind C-j run -b "#{@fingers-cli} start #{pane_id} --patterns url,path --main-action :open:"
bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe "pbcopy"
bind -n DoubleClick1Pane select-pane -t = \; if-shell -F "#{||:#{pane_in_mode},#{mouse_any_flag}}" { send-keys -M } { copy-mode -H ; send-keys -X select-word ; run-shell -d 0.3 ; send-keys -X copy-pipe-and-cancel pbcopy }
bind -n TripleClick1Pane select-pane -t = \; if-shell -F "#{||:#{pane_in_mode},#{mouse_any_flag}}" { send-keys -M } { copy-mode -H ; send-keys -X select-line ; run-shell -d 0.3 ; send-keys -X copy-pipe-and-cancel pbcopy }
bind -n WheelUpPane if -F "#{mouse_any_flag}" 'send C-y' 'if -F "#{alternate_on}" "send C-y" "copy-mode -e"'
bind -n WheelDownPane if -F "#{mouse_any_flag}" 'send C-e' 'if -F "#{alternate_on}" "send C-e" "send -X cancel"'

# command aliases
set -g command-alias[10] EF="neww -S -n config 'nvim $XDG_CONFIG_HOME/tmux/tmux.conf $XDG_CONFIG_HOME/tmux/lazy.tmux'"
set -g command-alias[11] ER="source $XDG_CONFIG_HOME/tmux/tmux.conf \; source $XDG_CONFIG_HOME/tmux/lazy.tmux \; display 'Config reloaded'"
set -g command-alias[12] man="splitw -v -e MANPAGER='sh -c \"col -bx | bat -l man --paging always\"' man"
set -g command-alias[13] ssh="neww -d $XDG_CONFIG_HOME/tmux/scripts/ssh.sh"
set -g command-alias[14] toggle-status="if -F \"#{==:#{status},off}\" 'set status on' 'set status off'"
set -g command-alias[15] toggle-clipboard="if -F \"#{==:#{set-clipboard},on}\" 'set -s set-clipboard off; display \"System clipboard OFF\"' 'set -g set-clipboard on; display \"System clipboard ON\"'"
set -g command-alias[16] toggle-mouse="if -F \"#{mouse}\" 'set mouse off' 'set mouse on'"
set -g command-alias[17] yazi-popup="popup -E -w 95% -h 90% -d '#{pane_current_path}' -e TMUX_POPUP=1 nvim -u $XDG_CONFIG_HOME/tmux/custom/yazi_init.lua"
set -g command-alias[18] yazi="neww -c '#{pane_current_path}' yazi"
set -g command-alias[19] lzg="popup -E -w 95% -h 90% -d '#{pane_current_path}' -e TMUX_POPUP=1 $XDG_CONFIG_HOME/tmux/scripts/open-lazygit.sh"
set -g command-alias[20] lzd="if 'docker ps' 'popup -E -w 95% -h 90% -d \"#{pane_current_path}\" lazydocker' 'display \"Docker not running\"'"
set -g command-alias[21] btop="if -F \"#{e|<=:#{client_width},80}\" 'neww btop -p 1' \"popup -E -w 95% -h 90% btop -p 2\""
set -g command-alias[22] open="popup -E -w 95% -h 90% -e TMUX_POPUP=1 $XDG_CONFIG_HOME/tmux/scripts/open-path.sh"
set -g command-alias[23] popup-term="run $XDG_CONFIG_HOME/tmux/scripts/popup-term.sh"
set -g command-alias[24] memo="popup -E -w 95% -h 90% -e TMUX_POPUP=1 fzf-memo"
set -g command-alias[25] alfred="popup -E -w 95% -h 90% -e TMUX_POPUP=1 -e PAGER=fzf-preview 'alfred-cli | tmux loadb -'"
set -g command-alias[26] paste="run -b 'pbpaste | tmux load-buffer -' \; paste-buffer -d"

bind C-r ER
bind -n F3 if -F "#{==:#{pane_current_command},nvim}" "send F3" yazi-popup
bind F3 yazi-popup
bind C-y yazi
bind Tab last
bind ` lastp
unbind C-o
bind C-o open
bind F4 popup-term
bind C-t popup-term
bind C-f alfred
bind C-v paste
bind M-n run 'open -a Ghostty -n --args -e zsh'

# modal bindings
unbind b
bind C-b if -F "#{==:#{prefix2},C-b}" 'send C-b' 'choose-buffer -Z'
bind b run "tmux #{@wk_cmd_show} #{@wk_menu_buffers}"

unbind s
bind C-s choose-tree -Zs
bind s run "tmux #{@wk_cmd_show} #{@wk_menu_sessions}"

unbind w
bind C-w choose-tree -Zw
bind w run "tmux #{@wk_cmd_show} #{@wk_menu_windows}"

unbind p
bind C-p selectw -p
bind p run "tmux #{@wk_cmd_show} #{@wk_menu_panes}"

bind C-g lzg

bind a run "tmux #{@wk_cmd_show} #{@wk_menu_app}"
bind C-l run "tmux #{@wk_cmd_show} #{@wk_menu_layout}"
bind C-h run "tmux #{@wk_cmd_show} #{@wk_menu_help}"

bind ? copy-mode \; send "/"

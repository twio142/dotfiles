set-environment -g PATH "~/.local/bin:$PATH"

#### Plugins ####
# tmux-resurrect 
set -g @resurrect-strategy-nvim 'session'
set -g @resurrect-strategy-vim 'session'
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-save 'C-ß'
set -g @resurrect-restore 'C-®'

# tmux-fzf

TMUX_FZF_LAUNCH_KEY="C-f"
FZF_DEFAULT_OPTS='--layout=reverse --cycle --inline-info --color=fg+:-1,bg+:-1,hl:bright-red,hl+:red,pointer:bright-red,info:-1,prompt:-1 --pointer='
TMUX_FZF_OPTIONS="-p -w 100% -h 20 -x 0% -y 100% -m --preview-window=right,60% ${FZF_DEFAULT_OPTS}"
TMUX_FZF_ORDER="session|window|pane|buffer"
TMUX_FZF_PANE_FORMAT="#{?pane_active,●,-} #{pane_current_command} ▸ #{b:pane_current_path} #{?pane_marked,󰃀 ,}"
TMUX_FZF_WINDOW_FORMAT="#{?window_active,●,-} #{?#{==:#W,#{pane_current_command}},#W,#W (#{pane_current_command})}   #{window_panes}#{?window_marked_flag, 󰃀,}"
TMUX_FZF_SESSION_FORMAT="#{?session_attached,●,-}   #{session_windows} ▸ #{b:session_path}"
TMUX_FZF_MENU=\
"edit config\ntmux edit-config\n"\
"tmux manual\ntmux tmux-man\n"\
"bottom\ntmux bottom\n"\
"xplr\ntmux xplr\n"\
"lazygit\ntmux lazygit\n"\
"lazydocker\ntmux lazydocker\n"\
"confetty\ntmux neww timeout 3s $XDG_DATA_HOME/go/bin/confetty\n"\
"toggle status\ntmux toggle-status\n"

# catppuccin
if 'test "$(background)" = light' 'set -g @catppuccin_flavor "latte"' 'set -g @catppuccin_flavor "mocha"'
# latte, frappe, macchiato or mocha
set -g @catppuccin_window_default_text "#W"
set -g @catppuccin_window_default_color "#{thm_fg}"
set -g @catppuccin_window_current_text "#W"
set -g @catppuccin_window_current_background "#{thm_bg}"
set -g @catppuccin_window_status "icon"
set -g @catppuccin_icon_window_activity "󰏤"
set -g @catppuccin_icon_window_bell "󰂞"
set -g @catppuccin_icon_window_last "○"
set -g @catppuccin_icon_window_current "#[fg=#{thm_orange}]●#[fg=default]"
set -g @catppuccin_icon_window_zoom ""
#            
set -g @catppuccin_window_right_separator ""
set -g @catppuccin_window_middle_separator " █"
set -g @catppuccin_window_number_position "right"
set -g @catppuccin_status_background "default"
set -g @catppuccin_status_modules_right "directory git ssh"
set -g @catppuccin_status_modules_left "session"
set -g @catppuccin_status_fill "all"
set -g @catppuccin_status_left_separator ""
set -g @catppuccin_status_right_separator "null"
set -g @catppuccin_status_connect_separator "yes"
set -g @catppuccin_session_text "#S "
set -g @catppuccin_directory_text "#{b:pane_current_path} "
set -g @catppuccin_directory_icon ""
set -g @catppuccin_custom_plugin_dir "$XDG_CONFIG_HOME/tmux/custom/catppuccin"
set -g @catppuccin_menu_style "bg=default"
set -g @catppuccin_menu_selected_style "fg=#{thm_bg},bg=#{thm_magenta}"
set -g @catppuccin_mode_style "fg=#{thm_fg},bg=#{?#{==:#{@catppuccin_flavor},latte},#c6dcfb,#282099}"

# treemux
set -g @treemux-tree-nvim-init-file "$XDG_CONFIG_HOME/tmux/custom/treemux_init.lua"
set -g @treemux-nvim-command "$XDG_CONFIG_HOME/tmux/custom/treemux"
set -g @treemux-python-command "~/.local/bin/python3"
set -g @treemux-tree-width "32"
set -g @treemux-tree 'ctrl-9'

# extrakto
set -g @extrakto_fzf_header "f c o g"
set -g @extrakto_key 'ctrl-#'
set -g @extrakto_clip_tool 'tmux load-buffer -'
set -g @extrakto_copy_key 'ctrl-y'
set -g @extrakto_insert_key 'enter'
set -g @extrakto_split_size '20'
set -g @extrakto_popup_position '0,100'
set -g @extrakto_popup_size '100%,20'
set -g @extrakto_fzf_unset_default_opts "false"
set -g @extrakto_fzf_layout "reverse"
set -g @extrakto_editor "nvim"
set -g @extrakto_filter_order "word line-trim url all"

run "$XDG_CONFIG_HOME/tmux/plugins/tpm/tpm" &
# Prefix I   install
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

# switch panes
bind h selectp -L
bind j selectp -D
bind k selectp -U
bind l selectp -R
bind -n C-h run "$XDG_CONFIG_HOME/tmux/scripts/switch.sh h"
bind -n C-j run "$XDG_CONFIG_HOME/tmux/scripts/switch.sh j"
bind -n C-k run "$XDG_CONFIG_HOME/tmux/scripts/switch.sh k"
bind -n C-l run "$XDG_CONFIG_HOME/tmux/scripts/switch.sh l"
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
set -g escape-time 15 # faster key response
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
set -s set-clipboard off # disable system clipboard
setw -g mode-keys vi # vi key bindings in copy mode
bind v copy-mode # enter copy mode
bind C-v copy-mode
bind -n M-v copy-mode
bind -T copy-mode-vi v send -X begin-selection # start selection with v
bind -T copy-mode-vi y send -X copy-selection # copy selection with y
bind -T copy-mode-vi Y send 'v$y' # copy to end of line
bind -T copy-mode-vi Enter send -X copy-selection-and-cancel \; paste-buffer # paste selection
bind -T copy-mode-vi C send -X copy-pipe "pbcopy"
bind -T copy-mode-vi O send -X copy-pipe-and-cancel "xargs -I _ open '_'"
bind -T copy-mode-vi i send -X cancel # cancel with Escape
bind -T copy-mode-vi M-Up send -X search-backward "^❯ "
bind -T copy-mode-vi M-Down send -X search-forward "^❯ "
bind -T copy-mode-vi C-h selectp -L
bind -T copy-mode-vi C-j selectp -D
bind -T copy-mode-vi C-k selectp -U
bind -T copy-mode-vi C-l selectp -R
bind -T copy-mode-vi m send -X set-mark
bind -T copy-mode-vi ` send -X jump-to-mark
bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe "pbcopy"
bind -n WheelUpPane if -F "#{mouse_any_flag}" 'send C-y' 'if -F "#{alternate_on}" "send C-y" "copy-mode -e"'
bind -n WheelDownPane if -F "#{mouse_any_flag}" 'send C-e' 'if -F "#{alternate_on}" "send C-e" "send -X cancel"'

# command aliases
set -g command-alias[10] EF="neww -S -n config 'nvim $XDG_CONFIG_HOME/tmux/tmux.conf $XDG_CONFIG_HOME/tmux/lazy.tmux'"
set -g command-alias[11] ER="source $XDG_CONFIG_HOME/tmux/tmux.conf \; source $XDG_CONFIG_HOME/tmux/lazy.tmux \;
display 'Config reloaded'"
set -g command-alias[12] man="splitw -v $XDG_CONFIG_HOME/tmux/scripts/man.sh"
set -g command-alias[13] tmux-man="splitw -v $XDG_CONFIG_HOME/tmux/scripts/man.sh tmux"
set -g command-alias[14] ssh="neww $XDG_CONFIG_HOME/tmux/scripts/ssh.sh"
set -g command-alias[15] toggle-status="if 'tmux show -q status | grep -q off' 'set status on' 'set status off'"
set -g command-alias[16] toggle-clipboard="if 'tmux show -g set-clipboard | grep -q on' 'set -g set-clipboard off; display \"Clipboard OFF\"' 'set -g set-clipboard on; display \"Clipboard ON\"'"
set -g command-alias[17] xplr="popup -E -w 95% -h 90% -x 3% -d '#{pane_current_path}' -e TMUX_POPUP=1 $XDG_CONFIG_HOME/tmux/scripts/open_xplr.sh"
set -g command-alias[18] yazi="neww -c '#{pane_current_path}' yazi"
set -g command-alias[19] lzg="popup -E -w 95% -h 90% -x 3% -d '#{pane_current_path}' $XDG_CONFIG_HOME/tmux/scripts/open_lazygit.sh"
set -g command-alias[20] lzd="if 'docker ps' 'popup -E -w 95% -h 90% -x 3% lazydocker' 'display \"Docker not running\"'"
set -g command-alias[21] btm="popup -E -w 95% -h 90% -x 3% '$SHELL -c \"btm --theme nord$(test $(background) = light && echo -light)\"'"
set -g command-alias[22] toggle-sidebar="run \"$XDG_CONFIG_HOME/tmux/plugins/treemux/scripts/toggle.sh '#{@treemux-key-Bspace}' '#{pane_id}'\""
set -g command-alias[23] open="popup -E -w 95% -h 90% -x 3% -e TMUX_POPUP=1 $XDG_CONFIG_HOME/tmux/scripts/open_path.sh"

bind C-r ER
bind M-h tmux-man
bind -n f3 xplr
bind Tab last
bind ` lastp
bind -n F1 if -F "#{==:#{pane_current_command},nvim}" "send F1" toggle-sidebar
unbind C-o
bind C-o open

# modal bindings
unbind b
bind C-b choose-buffer -Z
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
bind g run "tmux #{@wk_cmd_show} #{@wk_menu_git}"

bind C-l run "tmux #{@wk_cmd_show} #{@wk_menu_layout}"
bind C-a run "tmux #{@wk_cmd_show} #{@wk_menu_app}"
bind C-h run "tmux #{@wk_cmd_show} #{@wk_menu_help}"

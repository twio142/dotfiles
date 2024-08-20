version = '0.21.9'

local home = os.getenv("HOME")
local xpm_path = home .. "/.local/share/xplr/dtomvan/xpm.xplr"
local xpm_url = "https://github.com/dtomvan/xpm.xplr"
local conf_home = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")

package.path = package.path
  .. ";"
  .. xpm_path
  .. "/?.lua;"
  .. xpm_path
  .. "/?/init.lua;"
  .. conf_home
  .. "/xplr/?.lua"

os.execute(
  string.format(
    "[ -e '%s' ] || git clone '%s' '%s'",
    xpm_path,
    xpm_url,
    xpm_path
  )
)

require("layout")

require("xpm").setup({
  plugins = {
    'dtomvan/xpm.xplr',
    { name = 'dy-sh/dysh-style.xplr' },
    { name = 'dy-sh/get-rid-of-index.xplr' },
    { name = 'gitlab:hartan/web-devicons.xplr' },
    { name = 'sayanarijit/command-mode.xplr' },
    { name = 'sayanarijit/dual-pane.xplr' },
    { name = 'sayanarijit/fzf.xplr' },
    { name = 'sayanarijit/map.xplr' },
    { name = 'sayanarijit/trash-cli.xplr' },
    { name = 'sayanarijit/tree-view.xplr' },
    { name = 'sayanarijit/type-to-nav.xplr' },
  },
  auto_install = true,
  auto_cleanup = true,
})

xplr.config.general.table.header.cols = {
  { format = "╭─ path" },
  { format = "size" },
  { format = "perm" },
  { format = "modified" },
}
xplr.config.general.show_hidden = true
xplr.config.general.initial_sorting = {
  { sorter = "ByCanonicalIsFile" },
  { sorter = "ByIRelativePath" },
}
xplr.config.general.focus_ui.style.add_modifiers = { "Bold" }
xplr.config.node_types.symlink.meta.icon = xplr.util.paint(" ")

require("dual-pane").setup{
  active_pane_width = { Percentage = 50 },
  inactive_pane_width = { Percentage = 50 },
}

require("fzf").setup{
  mode = "default",
  key = "ctrl-f",
  bin = "fzf",
  args = " --preview '$XDG_CONFIG_HOME/fzf/fzf-preview.sh {}'",
  recursive = false,  -- If true, search all files under $PWD
  enter_dir = true,  -- Enter if the result is directory
}

require("trash-cli").setup{
  trash_bin = "trash -F",
  trash_mode = "delete",
  trash_key = "d",
  empty_bin = "trash -e -y",
  empty_mode = "delete",
  empty_key = "E",
}

require("autojump").setup{
  args = [[ --bind "start:reload:autojump --complete '' | awk -F '__' '{ if (!seen[tolower(\$3)]++) print \$3 }'" \
    --bind "change:reload:autojump --complete '{q}' | awk -F '__' '{ if (!seen[tolower(\$3)]++) print \$3 }'" \
    --disabled \
    --preview 'tree -C {} -L 4']],
  recursive = true,
  enter_dir = true,
  mode = "go_to",
  key = "j"
}

require("tree-view").setup({
  mode = "switch_layout",
  key = "t",
  -- If you feel slowness, you might want to toggle back to the default view.
  toggle_layout_mode = "default",
  toggle_layout_key = "esc",
  -- Press backspace to close all and back and close
  close_all_and_back_mode = "default",
  close_all_and_back_key = "backspace",
  -- Toggle expansion without entering
  toggle_expansion_mode = "default",
  toggle_expansion_key = "o",
  -- Toggle expansion of all the nodes under pwd
  toggle_expansion_all_mode = "default",
  toggle_expansion_all_key = "O",
  -- Focus on the next visible line, not compatible with up/down action
  focus_next_mode = "default",
  focus_next_key = "down",
  -- Focus on the previous visible line, not compatible with up/down action
  focus_prev_mode = "default",
  focus_prev_key = "up",
  -- Go to the next deep level directory that's open
  goto_next_open_mode = "default",
  goto_next_open_key = ")",
  -- Go to the previous deep level directory that's open
  goto_prev_open_mode = "default",
  goto_prev_open_key = "(",
  -- Whether to display the tree in full screen
  fullscreen = false,
  -- Indent for the branches of the tree
  indent = "  ",
  -- Start xplr with tree view layout
  as_initial_layout = false,
  -- Disables toggling layout.
  as_default_layout = false,
  -- Automatically fallback to this layout for better performance if the
  -- branch contains # of nodes more than the threshold value
  fallback_layout = "Table",
  fallback_threshold = 500,  -- default: nil (disabled)
})

require("keys")
require("bookmark")
require("preview")
require("commands")
require("git-status")

return {
  on_load = {
    {
      AddNodeFilter = {
        filter = "IRelativePathIsNot",
        input = ".DS_Store",
      }
    },
    {
      AddNodeFilter = {
        filter = "IRelativePathIsNot",
        input = ".localized",
      }
    },
  },
}

---@diagnostic disable: lowercase-global
version = '0.21.9'
_G.xplr = xplr

local home = os.getenv("HOME")
local xpm_path = (os.getenv("XDG_DATA_HOME") or (home .. "/.local/share")) .. "/xplr/dtomvan/xpm.xplr"
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

xplr.fn.custom.esc = function(ctx)
  if #ctx.selection > 0 then
    return { "ClearSelection" }
  else
    return { "Quit" }
  end
end
xplr.config.modes.builtin.default.key_bindings.on_key.esc = {
  help = "quit",
  messages = { { CallLuaSilently = "custom.esc" } }
}

require("layout")

require("xpm").setup({
  plugins = {
    { name = 'dtomvan/xpm.xplr', rev = 'main' },
    { name = 'dy-sh/dysh-style.xplr', rev = 'main' },
    { name = 'gitlab:hartan/web-devicons.xplr', rev = 'main' },
    { name = 'sayanarijit/command-mode.xplr', rev = 'main' },
    { name = 'sayanarijit/dual-pane.xplr', rev = 'main', setup = function()
      require("dual-pane").setup{
        active_pane_width = { Percentage = 50 },
        inactive_pane_width = { Percentage = 50 },
      }
    end },
    { name = 'sayanarijit/map.xplr', rev = 'main', setup = function()
      require('map').setup({
        mode = "selection_ops",
        key = "M",
        editor_key = "ctrl-e",
        prefer_multi_map = true,
      })
    end },
    { name = 'sayanarijit/tri-pane.xplr', rev = 'main', setup = function()
      require("tri-pane").setup({
        layout_key = "T",
        as_default_layout = false,
        left_pane_width = { Percentage = 15 },
        middle_pane_width = { Percentage = 50 },
        right_pane_width = { Percentage = 35 },
      })
    end },
    { name = 'sayanarijit/type-to-nav.xplr', rev = 'main' },
    { name = 'twio142/fzf.xplr', rev = 'main' },
    { name = 'twio142/tree-view.xplr', rev = 'main', setup = function()
      require("tree-view").setup({
        mode = "switch_layout",
        key = "t",
        -- If you feel slowness, you might want to toggle back to the default view.
        toggle_layout_mode = "default",
        toggle_layout_key = "t",
        -- Press backspace to close all and back and close
        close_all_and_back_mode = "default",
        close_all_and_back_key = "u",
        -- Toggle expansion without entering
        toggle_expansion_mode = "default",
        toggle_expansion_key = "o",
        -- Toggle expansion of all the nodes under pwd
        toggle_expansion_all_mode = "default",
        toggle_expansion_all_key = "}",
        -- Focus on the next visible line, not compatible with up/down action
        focus_next_mode = "default",
        focus_next_key = "j",
        -- Focus on the previous visible line, not compatible with up/down action
        focus_prev_mode = "default",
        focus_prev_key = "k",
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
    end },
  },
  auto_install = true,
  auto_cleanup = true,
})

xplr.config.general.scroll_padding = 5
xplr.config.general.show_hidden = true
xplr.config.general.focus_ui.style.add_modifiers = { "Bold" }
xplr.config.node_types.symlink.meta.icon = xplr.util.paint(" ", { fg = "Cyan" })
xplr.config.node_types.special[".git"] = { meta = { icon = xplr.util.paint(" ", { fg = "Blue"} ) }, style = { fg = "Blue" } }
xplr.config.general.logs.info.format = " "
xplr.config.general.logs.success.format = "󰸞 "
xplr.config.general.logs.error.format = " "
xplr.config.general.logs.warning.format = "󱈸 "
xplr.config.modes.builtin.move_to.prompt = "󱀱 ❯ "
xplr.config.modes.builtin.copy_to.prompt = " ❯ "
xplr.config.general.hide_remaps_in_help_menu = true
xplr.config.general.sort_and_filter_ui.sort_direction_identifiers.forward.format = ""
xplr.config.general.sort_and_filter_ui.sort_direction_identifiers.reverse.format = ""
xplr.config.general.sort_and_filter_ui.sorter_identifiers.ByLastModified.format = "mtime"
xplr.config.general.sort_and_filter_ui.sorter_identifiers.ByCreated.format = "ctime"
xplr.config.general.sort_and_filter_ui.sorter_identifiers.ByCanonicalLastModified.format = "[c]mtime"
xplr.config.general.sort_and_filter_ui.sorter_identifiers.ByCanonicalCreated.format = "[c]ctime"
xplr.config.general.sort_and_filter_ui.sorter_identifiers.BySymlinkLastModified.format = "[s]mtime"
xplr.config.general.sort_and_filter_ui.sorter_identifiers.BySymlinkCreated.format = "[s]ctime"

require("leader")
require("keys")
require("bookmark")
require("commands")
require("preview")
require("git-status")
require("complete-path")
require("load-fzf")
require("shell")

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
    "ExplorePwd"
  },
}

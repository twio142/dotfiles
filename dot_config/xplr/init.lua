version = '0.21.9'

local home = os.getenv("HOME")
local xpm_path = home .. "/.local/share/xplr/dtomvan/xpm.xplr"
local xpm_url = "https://github.com/dtomvan/xpm.xplr"

package.path = package.path
  .. ";"
  .. xpm_path
  .. "/?.lua;"
  .. xpm_path
  .. "/?/init.lua"

local conf_dir = os.getenv("XDG_CONFIG_HOME") or ( home .. "/.config" )
package.path = package.path
  .. ";"
  .. conf_dir
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
  },
  auto_install = true,
  auto_cleanup = true,
})

xplr.config.modes.builtin.default.key_bindings.on_key.x = {
  help = "xpm",
  messages = {
    "PopMode",
    { SwitchModeCustom = "xpm" },
  },
}

xplr.config.general.show_hidden = true
xplr.config.general.initial_sorting = { 
  { sorter = "ByCanonicalIsFile" },
  { sorter = "ByLastModified", reverse = true },
}
xplr.config.general.focus_ui.style.add_modifiers = { "Bold" }
xplr.config.node_types.symlink.meta.icon = xplr.util.paint(" ")

require("dual-pane").setup{
  active_pane_width = { Percentage = 50 },
  inactive_pane_width = { Percentage = 50 },
}

require("command-mode-config")

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

require("keys")
require("bookmark")
require("preview")

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

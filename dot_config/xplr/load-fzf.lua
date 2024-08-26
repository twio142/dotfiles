require("fzf").setup{
  name = "autojump",
  args = [[ --bind "start:reload:autojump --complete '' | awk -F '__' '{ if (!seen[tolower(\$3)]++) print \$3 }'" \
    --bind "change:reload:autojump --complete '{q}' | awk -F '__' '{ if (!seen[tolower(\$3)]++) print \$3 }'" \
    --disabled --preview 'tree -C {} -L 4' | xargs -I _ rp "_" ]],
  recursive = true,
  enter_dir = true,
  mode = "go_to",
  key = "g"
}

require("fzf").setup{
  name = "fif",
  bin = "fif",
  args = "-o",
  recursive = true,
  mode = "search",
  key = "ctrl-v",
  callback = "custom.fif_callback"
}

xplr.fn.custom.fif_callback = function(input)
  local path, line = input:match("^([^:]+):(%d+):")
  path = xplr.util.shell_escape(path)
  return {
    { BashExec = string.format("nvim +%s %s", line, path) },
    "PopMode",
  }
end

require("fzf").setup{
  name = "recent files",
  bin = "cat",
  args = os.getenv("XDG_CACHE_HOME") .. "/neomru/file | sed '2,10!d' | fzf -m --preview 'bat --color=always {}'",
  recursive = true,
  key = "ctrl-r",
}

xplr.fn.custom.edit_files = function(input)
  local cmd = "nvim "
  if #input > 0 and type(input[1]) == "string" then
    for _, file in ipairs(input) do
      cmd = cmd .. xplr.util.shell_escape(file) .. " "
    end
  elseif input.selection and #input.selection > 0 then
    for _, node in ipairs(input.selection) do
      cmd = cmd .. xplr.util.shell_escape(node.absolute_path) .. " "
    end
  end
  return { { BashExec0 = cmd } }
end

xplr.config.modes.custom.space.key_bindings.on_key.r = {
  help = "recent files",
  messages = {
    "PopMode",
    { CallLua = "custom.recent_files.search" },
  },
}

xplr.config.modes.builtin.selection_ops.key_bindings.on_key.E = xplr.config.modes.builtin.selection_ops.key_bindings.on_key.e
xplr.config.modes.builtin.selection_ops.key_bindings.on_key.e = {
  help = "edit selected files",
  messages = {
    "PopMode",
    { CallLua = "custom.edit_files" },
  },
}

xplr.config.modes.custom.backslash.key_bindings.on_key.f = {
  help = "fzf",
  messages = {
    "PopMode",
    { CallLua = "custom.fzf.search" },
  },
}

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

xplr.config.modes.custom.backslash.key_bindings.on_key.g = {
  help = "autojump",
  messages = {
    "PopMode",
    { CallLua = "custom.autojump.search" },
  },
}

require("fzf").setup{
  name = "fif",
  bin = "fif",
  args = "-o",
  recursive = true,
  mode = "custom.backslash",
  key = "s",
  callback = "custom.fif_callback"
}

xplr.fn.custom.fif_callback = function(input)
  -- if multiple lines are selected, open them all in nvim
  -- if a single line is selected, open the file at the line number in nvim
  local cmd = "nvim "
  if #input > 1 then
    for _, i in ipairs(input) do
      local path = i:match("^([^:]+):%d+:")
      cmd = cmd .. xplr.util.shell_escape(path) .. " "
    end
  elseif #input == 1 then
    local path, line = input[1]:match("^([^:]+):(%d+):")
    path = xplr.util.shell_escape(path)
    cmd = cmd .. "+" .. line .. " " .. path
  else
    return
  end
  return {
    { BashExec = cmd },
    "PopMode",
  }
end

require("fzf").setup{
  name = "recent files",
  bin = "cat",
  args = os.getenv("XDG_CACHE_HOME") .. "/neomru/file | sed '2,10!d' | fzf -m --preview 'bat --color=always {}'",
  recursive = true,
  mode = "custom.backslash",
  key = "r",
}

require("fzf").setup{
  name = "recent repos",
  bin = "awk",
  args = "'/recentrepos:/ {found=1; next} found && /^[^[:space:]]/ {exit} found {print}' $XDG_STATE_HOME/lazygit/state.yml | sd '^ +- ' '' | grep -Fxv \"$PWD\" | fzf --preview \"git -c color.status=always -C {} status | sd ' +\\(use \\\"git [^)]+\\)' ''\" --preview-window=wrap" ,
  recursive = true,
  enter_dir = true,
  mode = "custom.backslash",
  key = "p",
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

xplr.config.modes.builtin.selection_ops.key_bindings.on_key.E = xplr.config.modes.builtin.selection_ops.key_bindings.on_key.e
xplr.config.modes.builtin.selection_ops.key_bindings.on_key.e = {
  help = "edit selected files",
  messages = {
    "PopMode",
    { CallLua = "custom.edit_files" },
  },
}

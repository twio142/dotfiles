local m = require("command-mode")
-- m.setup()

local open_in_vscode = m.silent_cmd("vscode", "open in VSCode")(
  m.BashExecSilently [===[
    code "$PWD"
    sleep 1
    code -g "${XPLR_FOCUS_PATH:?}"
  ]===]
)

local preview = m.silent_cmd("preview", "preview file")(
  m.BashExecSilently [===[
    $XDG_CONFIG_HOME/fzf/fzf-preview.sh "${XPLR_FOCUS_PATH:?}" | less -R
  ]===]
)

local compare = m.cmd("compare", "compare files")(function(ctx)
  if #ctx.selection ~= 2 then
    return { { LogError = "Please select exactly 2 files to compare" } }
  end
  local paths = xplr.util.shell_escape(ctx.selection[1].absolute_path) .. " " .. xplr.util.shell_escape(ctx.selection[2].absolute_path)
  return { { BashExec = [[ delta --$(~/bin/background) --navigate --tabs=2 --line-numbers --side-by-side --paging=always ]] .. paths } }
end)

local copy_path = m.silent_cmd("copy-path", "copy file path")(function(ctx)
  local path = ctx.focused_node.absolute_path
  os.execute("printf " .. xplr.util.shell_escape(path) .. " | pbcopy")
  return {
    { LogSuccess = "Copied to clipboard: " .. path }
  }
end)

local tmux_buffer = m.silent_cmd("tmux-buffer", "copy file path to tmux buffer")(function(ctx)
  local path = ctx.focused_node.absolute_path
  os.execute("printf " .. xplr.util.shell_escape(path) .. " | tmux load-buffer -")
  return {
    { LogSuccess = "Copied to tmux buffer" },
  }
end)

local browse_in_alfred = m.silent_cmd("browse-in-alfred", "browse in alfred")(
  m.BashExecSilently [[ alfred "${XPLR_FOCUS_PATH:?}" ]]
)

local add_to_alfred_buffer = m.silent_cmd("add-to-alfred-buffer", "add to alfred buffer")(function(ctx)
  local args = { "-w", "com.nyako520.syspre", "-t", "buffer", "-a", "-" }
  if #ctx.selection > 0 then
    for _, node in ipairs(ctx.selection) do
      table.insert(args, node.absolute_path)
    end
  else
    table.insert(args, ctx.focused_node.absolute_path)
  end
  xplr.util.shell_execute("altr", args)
end)

local cd_in_tmux = m.cmd("cd-in-tmux", "cd path in tmux")(function(ctx)
  if os.getenv("TMUX") == nil then
    return { { LogError = "Not in tmux" } }
  end
  local pid = xplr.util.shell_execute("tmux", { "display", "-p", "#{client_pid}" }).stdout:match("(%d+)")
  local scpt = os.getenv("XDG_CONFIG_HOME") .. "/tmux/scripts/find_empty_shell.sh"
  local path = ctx.focused_node.absolute_path
  xplr.util.shell_execute(scpt, { pid, "lc " .. xplr.util.shell_escape(path) })
  return { "Quit" }
end)

local vim_in_tmux = m.cmd("vim-in-tmux", "edit file(s) in tmux")(function(ctx)
  if os.getenv("TMUX") == nil then
    return { { LogError = "Not in tmux" } }
  end
  local pid = xplr.util.shell_execute("tmux", { "display", "-p", "#{pane_current_command} #{client_pid}" }).stdout:match("(%d+)")
  local scpt = os.getenv("XDG_CONFIG_HOME") .. "/tmux/scripts/open_in_vim.sh"
  local args = { pid }
  if #ctx.selection > 0 then
    for _, node in ipairs(ctx.selection) do
      table.insert(args, node.absolute_path)
    end
  else
    table.insert(args, ctx.focused_node.absolute_path)
  end
  xplr.util.shell_execute(scpt, args)
  return { "Quit" }
end)

preview.bind(xplr.config.modes.custom.preview, "`")
-- xplr.config.modes.custom.preview.key_bindings.on_key.w = preview.action
copy_path.bind(xplr.config.modes.builtin.default, "y")
tmux_buffer.bind(xplr.config.modes.builtin.default, "ctrl-y")
browse_in_alfred.bind(xplr.config.modes.builtin.default, "a")
add_to_alfred_buffer.bind(xplr.config.modes.builtin.default, "=")
cd_in_tmux.bind(xplr.config.modes.builtin.default, "enter")
vim_in_tmux.bind(xplr.config.modes.builtin.default, "e")

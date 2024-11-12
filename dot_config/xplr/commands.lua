_G.xplr = xplr
local m = require("command-mode")
-- m.setup()

xplr.config.modes.custom.command_mode.key_bindings.on_key[":"] = {
  help = "shell",
  messages = {
    { Call = { command = os.getenv("SHELL"), args = { "-i" } } },
    "ExplorePwdAsync",
    "PopMode",
  }
}
xplr.config.modes.custom.command_mode.key_bindings.on_key["!"] = nil

m.silent_cmd("vscode", "open in VSCode")(
  m.BashExecSilently [===[
    code "$PWD"
    sleep 1
    code -g "${XPLR_FOCUS_PATH:?}"
  ]===]
)

local preview = m.silent_cmd("preview", "[p]review file")(
  m.BashExec [[ fzf-preview "${XPLR_FOCUS_PATH:?}" | less -r ]]
)

local dust = m.cmd("dust", "disk usage")(
  m.BashExec [===[
    read -r r c < <(stty size < /dev/tty)
    dust -C -w $(( c - 1 )) -n $(( r - 2 )) | less -r
  ]===]
)

local diff = m.cmd("diff", "[d]iff files")(function(ctx)
  if #ctx.selection ~= 2 then
    return { { LogError = "Please select exactly 2 files to compare" } }
  end
  local paths = xplr.util.shell_escape(ctx.selection[1].absolute_path) .. " " .. xplr.util.shell_escape(ctx.selection[2].absolute_path)
  return { { BashExec = [[ delta --$(background) --navigate --tabs=2 --line-numbers --side-by-side --paging=always --width=$(stty size < /dev/tty | choose 1) ]] .. paths .. " | less -r" } }
end)

local yank_path = m.silent_cmd("yank-path", "[y]ank file path")(function(ctx)
  local path = ctx.focused_node.absolute_path
  os.execute("printf " .. xplr.util.shell_escape(path) .. " | pbcopy")
  return { { LogSuccess = "Copied to clipboard: " .. path } }
end)

local paste_path = m.silent_cmd("paste-path", "[p]aste file path")(function()
  local path = xplr.util.shell_execute("pbpaste").stdout
  if not xplr.util.exists(path) then
    return { { LogError = "No path in clipboard" } }
  elseif xplr.util.is_dir(path) then
    return { { ChangeDirectory = path } }
  else
    return { { FocusPath = path } }
  end
end)

local yank_to_tmux = m.silent_cmd("yank-to-tmux", "[Y]ank file path to tmux buffer")(function(ctx)
  local path = ctx.focused_node.absolute_path
  os.execute("printf " .. xplr.util.shell_escape(path) .. " | tmux load-buffer -")
  return { { LogSuccess = "Copied to tmux buffer: " .. path } }
end)

local paste_from_tmux = m.silent_cmd("paste-from-tmux", "[P]aste file path from tmux buffer")(function()
  local path = xplr.util.shell_execute("tmux", { "show-buffer" }).stdout
  if not xplr.util.exists(path) then
    return { { LogError = "No path in tmux buffer" } }
  elseif xplr.util.is_dir(path) then
    return { { ChangeDirectory = path } }
  else
    return { { FocusPath = path } }
  end
end)

local browse_in_alfred = m.silent_cmd("browse-in-alfred", "browse in [a]lfred")(
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

local alfred_action = m.silent_cmd("alfred-action", "alfred action")(function(ctx)
  local args = { "-w", "com.nyako520.alfred", "-t", "action", "-a", "-" }
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
  xplr.util.shell_execute(scpt, { pid, "cd", ctx.pwd })
  return { "Quit" }
end)

local cd_in_tmux_neww = m.cmd("cd-in-tmux-neww", "cd path in new tmux window")(function(ctx)
  if os.getenv("TMUX") == nil then
    return { { LogError = "Not in tmux" } }
  end
  local pid = xplr.util.shell_execute("tmux", { "display", "-p", "#{client_pid}" }).stdout:match("(%d+)")
  local scpt = os.getenv("XDG_CONFIG_HOME") .. "/tmux/scripts/find_empty_shell.sh"
  xplr.util.shell_execute(scpt, { pid, "-n", "cd", ctx.pwd })
  return { "Quit" }
end)

local vim_in_tmux = m.cmd("vim-in-tmux", "[e]dit file(s) in tmux")(function(ctx)
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

local vim_in_tmux_neww = m.cmd("vim-in-tmux-neww", "[E]dit file(s) in new tmux window")(function(ctx)
  if os.getenv("TMUX") == nil then
    return { { LogError = "Not in tmux" } }
  end
  local pid = xplr.util.shell_execute("tmux", { "display", "-p", "#{pane_current_command} #{client_pid}" }).stdout:match("(%d+)")
  local scpt = os.getenv("XDG_CONFIG_HOME") .. "/tmux/scripts/open_in_vim.sh"
  local args = { pid, "-n" }
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

m.cmd("fif", "search file contents")(function()
  return { "PopMode", { CallLua = "custom.fif.search" } }
end)

local edit = m.cmd("edit", "edit file(s)")(function(ctx)
  local cmd = "${EDITOR:-vi} "
  if #ctx.selection > 0 then
    for _, node in ipairs(ctx.selection) do
      cmd = cmd .. xplr.util.shell_escape(node.absolute_path) .. " "
    end
  else
    cmd = cmd .. xplr.util.shell_escape(ctx.focused_node.absolute_path)
  end
  return {{ BashExec0 = cmd }}
end)

preview.bind(xplr.config.modes.builtin.action, "p")
-- xplr.config.modes.custom.preview.key_bindings.on_key.P = preview.action
dust.bind(xplr.config.modes.custom.space, "u")
diff.bind(xplr.config.modes.builtin.selection_ops, "d")
yank_path.bind(xplr.config.modes.builtin.default, "y")
paste_path.bind(xplr.config.modes.builtin.default, "p")
yank_to_tmux.bind(xplr.config.modes.custom.space, "y")
paste_from_tmux.bind(xplr.config.modes.custom.space, "p")
browse_in_alfred.bind(xplr.config.modes.builtin.default, "a")
add_to_alfred_buffer.bind(xplr.config.modes.builtin.default, "=")
alfred_action.bind(xplr.config.modes.builtin.default, "x")
alfred_action.bind(xplr.config.modes.builtin.selection_ops, "x")
cd_in_tmux.bind(xplr.config.modes.builtin.default, "enter")
cd_in_tmux_neww.bind(xplr.config.modes.custom.space, "enter")
vim_in_tmux.bind(xplr.config.modes.builtin.default, "e")
vim_in_tmux_neww.bind(xplr.config.modes.builtin.default, "E")
edit.bind(xplr.config.modes.builtin.default, "ctrl-e")

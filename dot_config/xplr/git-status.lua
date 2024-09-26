_G.xplr = xplr

xplr.config.modes.custom.git_status = {
  key_bindings = xplr.config.modes.builtin.default.key_bindings,
  layout = { Dynamic = "custom.git_status.setup" },
}

local function format_status(text)
  local function split_lines(t)
    t = t .. "\n"
    local lines = {}
    for line in t:gmatch("([^\n]*)\n") do
      table.insert(lines, line)
    end
    return lines
  end

  local lines = {}
  local style = {}

  for i, line in pairs(split_lines(text)) do
    if i == 1 then
      if line:match("^On branch") then
        line = line:gsub("^(On branch )([^ ]+)", "%1" .. xplr.util.paint("%2", { add_modifiers = { "Bold" } }))
      elseif line:match("^HEAD detached at") then
        line = line:gsub("^(HEAD detached at) ([^ ]+)", xplr.util.paint("%1", { fg = "Red" }) .. xplr.util.paint("%2", { add_modifiers = { "Bold" } }))
      end
      table.insert(lines, line)
    elseif line:match(' %(use "git .+') then
      line = line:gsub(' +%(use "git [^)]+%)', "")
      if line ~= "" then
        table.insert(lines, line)
      end
    elseif line:match("^Changes to be committed:") then
      table.insert(lines, line)
      style = { fg = "Green" }
    elseif line:match("^Changes not staged for commit:") then
      table.insert(lines, line)
      style = { fg = "Red" }
    elseif line:match("^Untracked files:") then
      table.insert(lines, line)
      style = { fg = "Yellow" }
    elseif line == "" then
      table.insert(lines, line)
      style = {}
    elseif style ~= {} then
      table.insert(lines, xplr.util.paint(line, style))
    end
  end

  return table.concat(lines, "\n")
end

local function setup(ctx)
  local layout = xplr.util.layout_replace(ctx.app.layout, "Selection", { Dynamic = "custom.git_status.render" })
  return { CustomLayout = layout }
end

local function render(ctx)
  local path = ctx.app.focused_node.absolute_path
  if path:match("/.git$") or xplr.util.is_file(path) then
    path = xplr.util.dirname(path)
  end
  local test = xplr.util.shell_execute("git", { "-C", path, "rev-parse", "--show-toplevel" })
  local body
  if test.returncode ~= 0 then
    body = xplr.util.paint(test.stderr, { fg = "Red" })
  else
    local git_dir = test.stdout:gsub("\n", "")
    body = xplr.util.paint(git_dir, { add_modifiers = { "Underlined" }}) .. "\n\n"
    local dir = ctx.app.pwd
    if not xplr.util.relative_to(git_dir):match("^%.") then
      dir = git_dir
    end
    local status = xplr.util.shell_execute("git", { "-C", dir, "status" }).stdout
    body = body .. xplr.fn.custom.git_status.format(status)
  end
  return {
    CustomParagraph = {
      ui = { title = { format = " Git Status " } },
      body = body,
    }
  }
end

local function lazygit(ctx)
  local pwd = ctx.pwd
  local test = xplr.util.shell_execute("git", { "-C", pwd, "rev-parse", "--show-toplevel" })
  if test.returncode ~= 0 then
    pwd = ctx.focused_node.absolute_path
    if xplr.util.is_file(pwd) then
      pwd = xplr.util.dirname(pwd)
    end
    test = xplr.util.shell_execute("git", { "-C", pwd, "rev-parse", "--show-toplevel" })
  end
  if test.returncode ~= 0 then
    return {{ LogError = test.stderr }}
  else
    return {{ BashExec = "lazygit -p " .. xplr.util.shell_escape(pwd) }}
  end
end

xplr.fn.custom.git_status = {
  setup = setup,
  render = render,
  format = format_status,
  lazygit = lazygit,
}

xplr.config.modes.builtin.go_to.key_bindings.on_key.s = {
  help = "git [s]tatus",
  messages = {
    "PopMode",
    { SwitchModeCustom = "git_status" },
  },
}

xplr.config.modes.builtin.go_to.key_bindings.on_key.S = {
  help = "LazyGit",
  messages = {
    "PopMode",
    { CallLuaSilently = "custom.git_status.lazygit" },
  },
}


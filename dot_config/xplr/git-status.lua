xplr.config.modes.custom.git_status = {
  key_bindings = xplr.config.modes.builtin.default.key_bindings,
  layout = { Dynamic = "custom.git_status.setup" },
}

local function format_status(text)
  local function split_parts(text)
    text = text .. "\n\n"
    local parts = {}
    for part in text:gmatch("(.-)\n\n") do
      table.insert(parts, part)
    end
    return parts
  end

  local function split_lines(text)
    text = text .. "\n"
    local lines = {}
    for line in text:gmatch("([^\n]+)\n") do
      table.insert(lines, line)
    end
    return lines
  end

  local parts = split_parts(text)
  for i, part in pairs(parts) do
    if part:match("^Changes to be committed:") then
      local lines = split_lines(part)
      parts[i] = lines[1] .. "\n" ..xplr.util.paint(table.concat(lines, "\n", 3), { fg = "Green" })
    elseif part:match("^Changes not staged for commit:") then
      local lines = split_lines(part)
      parts[i] = lines[1] .. "\n" ..xplr.util.paint(table.concat(lines, "\n", 4), { fg = "Red" })
    elseif part:match("^Untracked files:") then
      local lines = split_lines(part)
      parts[i] = lines[1] .. "\n" ..xplr.util.paint(table.concat(lines, "\n", 3), { fg = "Yellow" })
    end
  end
  text = table.concat(parts, "\n\n"):gsub("^On branch ([^ ]+)\n", "On branch " .. xplr.util.paint("%1", { add_modifiers = { "Bold" } }) .. "\n")
  return text
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

xplr.fn.custom.git_status = {
  setup = setup,
  render = render,
  format = format_status,
}

xplr.config.modes.builtin.go_to.key_bindings.on_key.s = {
  help = "git status",
  messages = {
    "PopMode",
    { SwitchModeCustom = "git_status" },
  },
}


_G.xplr = xplr

xplr.config.modes.builtin.default.key_bindings.on_key.P = {
  help = "toggle [P]review",
  messages = { { CallLuaSilently = "custom.preview.toggle" } }
}

xplr.config.modes.custom.preview = {
  name = "preview",
  key_bindings = xplr.util.clone(xplr.config.modes.builtin.default.key_bindings),
  layout = { Dynamic = "custom.preview.setup" },
}

local on_key = xplr.config.modes.custom.preview.key_bindings.on_key

on_key["ctrl-d"] = {
  help = "scroll down preview",
  messages = { { CallLuaSilently = "custom.preview.scroll_down" } }
}

on_key["ctrl-u"] = {
  help = "scroll up preview",
  messages = { { CallLuaSilently = "custom.preview.scroll_up" } }
}

on_key["ctrl-g"] = {
  help = "scroll preview to top / bottom",
  messages = { { CallLuaSilently = "custom.preview.scroll_to_end" } }
}

on_key.z = {
  help = "fullscreen preview",
  messages = { { CallLuaSilently = "custom.preview.fullscreen" } }
}

local state = {
  file = nil,
  start_from = 0,
  preview = "",
}

local function create_preview(node, size)
  local path = node.absolute_path
  if state.file ~= path then
    state.start_from = 0
    state.file = path
    state.preview = ""
  end
  if state.preview == "" then
    local cmd = "TMUX_POPUP=1 FZF_PREVIEW_COLUMNS=" .. size.width-1 .." FZF_PREVIEW_LINES=" .. size.height-1 .. " fzf-preview " .. xplr.util.shell_escape(path)
    local p = io.popen(cmd, "r")
    if p then
      state.preview = p:read("*a")
      p:close()
    end
  end
  if state.start_from == 0 then
    return state.preview
  end
  local lines = {}
  for l in state.preview:gmatch("([^\n]*)\n") do
    table.insert(lines, l)
  end
  if state.start_from > #lines - size.height + 2 then
    state.start_from = #lines - size.height + 2
  end
  for _ = 1, state.start_from do
    table.remove(lines, 1)
  end
  return table.concat(lines, "\n")
end

local function setup_preview(ctx)
  local layout = xplr.util.layout_replace(ctx.app.layout, "Selection", { Dynamic = "custom.preview.render" })
  return { CustomLayout = layout }
end

local function render_preview(ctx)
  return {
    CustomParagraph = {
      ui = { title = { format = " Preview " } },
      body = xplr.fn.custom.preview.create(ctx.app.focused_node, ctx.layout_size),
    }
  }
end

local function scroll_up()
  state.start_from = state.start_from - 5
  if state.start_from < 0 then
    state.start_from = 0
  end
  return { "PopMode", { SwitchModeCustom = "preview" } }
end

local function scroll_down()
  state.start_from = state.start_from + 5
  return { "PopMode", { SwitchModeCustom = "preview" } }
end

local function scroll_to_end()
  if state.start_from == 0 then
    state.start_from = 9999999
  else
    state.start_from = 0
  end
  return { "PopMode", { SwitchModeCustom = "preview" } }
end

local function toggle_preview(ctx)
  if ctx.mode.name == "preview" then
    return { "PopMode" }
  else
    return { "PopMode", { SwitchModeCustom = "preview" } }
  end
end

local function fullscreen_preview()
  return { { BashExec0 = [[ fzf-preview "${XPLR_FOCUS_PATH:?}" | less -r ]] } }
end

xplr.fn.custom.preview = {
  create = create_preview,
  setup = setup_preview,
  render = render_preview,
  toggle = toggle_preview,
  scroll_up = scroll_up,
  scroll_down = scroll_down,
  scroll_to_end = scroll_to_end,
  fullscreen = fullscreen_preview,
}


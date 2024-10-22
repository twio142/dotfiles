_G.xplr = xplr

xplr.config.modes.builtin.default.key_bindings.on_key.P = {
  help = "toggle preview",
  messages = { { CallLuaSilently = "custom.preview.toggle" } }
}

xplr.config.modes.custom.preview = {
  name = "preview",
  key_bindings = xplr.config.modes.builtin.default.key_bindings,
  layout = { Dynamic = "custom.preview.setup" },
}

local function create_preview(node, size)
  local path = node.absolute_path
  local cmd = "TMUX_POPUP=1 FZF_PREVIEW_COLUMNS=" .. size.width-1 .." FZF_PREVIEW_LINES=" .. size.height-1 .. " fzf-preview " .. xplr.util.shell_escape(path)
  local p = io.popen(cmd, "r")
  if p then
    local output = p:read("*a")
    p:close()
    return output
  end
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

local function toggle_preview(ctx)
  if ctx.mode.name == "preview" then
    return { "PopMode" }
  else
    return { "PopMode", { SwitchModeCustom = "preview" } }
  end
end

xplr.fn.custom.preview = {
  create = create_preview,
  setup = setup_preview,
  render = render_preview,
  toggle = toggle_preview,
}


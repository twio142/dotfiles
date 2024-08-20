xplr.config.modes.custom.git_status = {
  key_bindings = {
    on_key = {
      esc = {
        help = "exit",
        messages = { "PopMode" },
      },
    },
    default = {
      messages = { "PopMode" },
    },
  },
  layout = { Dynamic = "custom.git_status" },
}

xplr.fn.custom.git_status = function(ctx)
  local path = ctx.app.focused_node.absolute_path
  if path:match("/.git$") or xplr.util.is_file(path) then
    path = xplr.util.dirname(path)
  end
  local test = xplr.util.shell_execute("git", { "-C", path, "rev-parse", "--show-toplevel" })
  if test.returncode ~= 0 then
    body = test.stderr
  else
    local git_dir = test.stdout:gsub("\n", "")
    body = xplr.util.shell_execute("git", { "-C", git_dir, "status" }).stdout
  end
  local layout = {
    Static = {
      CustomParagraph = {
        ui = { title = { format = " Git Status " } },
        body = body,
      }
    }
  }
  return { CustomLayout = xplr.util.layout_replace(ctx.app.layout, "Selection", layout) }
end

xplr.config.modes.builtin.go_to.key_bindings.on_key.s = {
  help = "git status",
  messages = {
    "PopMode",
    { SwitchModeCustom = "git_status" },
  },
}


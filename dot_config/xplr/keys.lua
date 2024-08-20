local on_key = xplr.config.modes.builtin.default.key_bindings.on_key

on_key["alt-j"] = on_key["}"]
on_key["alt-k"] = on_key["{"]

on_key["ctrl-v"] = {
  help = "action selected files",
  messages = {
    "PopMode",
    { SwitchModeBuiltin = "selection_ops" },
  }
}

-- xpm
on_key.x = {
  help = "xpm",
  messages = {
    "PopMode",
    { SwitchModeCustom = "xpm" },
  },
}

-- type-to-nav
on_key.i = {
  help = 'type-to-nav',
  messages = { { CallLuaSilently = 'custom.type_to_nav_start' } },
}
on_key.I = {
  help = 'type-to-nav',
  messages = { { CallLuaSilently = 'custom.type_to_nav_start_selecting' } },
}
xplr.config.modes.custom.type_to_nav.key_bindings.on_key.up = {
  help = 'focus previous',
  messages = { 'FocusPrevious' },
}
xplr.config.modes.custom.type_to_nav.key_bindings.on_key.down = {
  help = 'focus next',
  messages = { 'FocusNext' },
}
xplr.config.modes.custom.type_to_nav.key_bindings.on_key.left = {
  help = 'go back',
  messages = { { CallLuaSilently = 'custom.type_to_nav_up' } },
}
xplr.config.modes.custom.type_to_nav.key_bindings.on_key.right = {
  help = 'accept',
  messages = { { CallLuaSilently = 'custom.type_to_nav_accept' } },
}
xplr.config.modes.custom.type_to_nav.key_bindings.on_key['ctrl-v'] = {
  help = 'toggle selecting',
  messages = { { CallLuaSilently = 'custom.type_to_nav_start_selecting' } },
}
xplr.config.modes.custom.type_to_nav.key_bindings.on_key['ctrl-s'] = {
  help = 'toggle select',
  messages = { 'ToggleSelection', 'FocusNext' },
}

-- dual-pane
on_key["ctrl-h"] = {
  messages = {
    "PopMode",
    { CallLuaSilently = "custom.dual_pane.activate_left_pane" },
  },
}
on_key["ctrl-l"] = {
  messages = {
    "PopMode",
    { CallLuaSilently = "custom.dual_pane.activate_right_pane" },
  },
}

-- paste and move selected files
xplr.fn.custom.pasteSelected = function(ctx)
  if #ctx.selection == 0 then
    return { { LogError = "No files selected" } }
  end
  local args = { "-r" }
  for _, node in ipairs(ctx.selection) do
    table.insert(args, node.absolute_path)
  end
  local target = ctx.focused_node.absolute_path
  if xplr.util.is_file(target) then
    target = xplr.util.dirname(target)
  end
  table.insert(args, target)
  xplr.util.shell_execute("cp", args)
  return { "ClearSelection" }
end

on_key.p = {
  help = "Paste selected files",
  messages = { { CallLua = "custom.pasteSelected" } }
}

xplr.fn.custom.moveSelected = function(ctx)
  if #ctx.selection == 0 then
    return { { LogError = "No files selected" } }
  end
  local args = {}
  for _, node in ipairs(ctx.selection) do
    table.insert(args, node.absolute_path)
  end
  local target = ctx.focused_node.absolute_path
  if xplr.util.is_file(target) then
    target = xplr.util.dirname(target)
  end
  table.insert(args, target)
  xplr.util.shell_execute("mv", args)
  return { "ClearSelection" }
end

on_key.P = {
  help = "move selected files",
  messages = { { CallLua = "custom.moveSelected" } }
}

-- create new file
xplr.config.modes.custom.new_file = {
  name = "create file",
  key_bindings = {
    on_key = {
      enter = {
        help = "confirm",
        messages = {
          { CallLuaSilently = "custom.new_file" },
          "PopMode",
        },
      },
      esc = {
        help = "cancel",
        messages = {
          "PopMode",
        },
      },
    },
    default = {
      messages = {
        "UpdateInputBufferFromKey",
      },
    },
  },
}

xplr.fn.custom.new_file = function(ctx)
  local target = ctx.pwd
  local filename = ctx.input_buffer:match("^%s*(.-)%s*$")
  if filename == "" then
    return {}
  else
    filename = ctx.pwd .. "/" .. filename
  end
  if string.sub(filename, -1) == '/' then
    xplr.util.shell_execute("mkdir", { "-p", filename })
  else
    xplr.util.shell_execute("touch", { filename })
  end
  return { FocusPath = filename }
end

on_key.N = {
  help = "new file",
  messages = {
    "PopMode",
    { SwitchModeCustom = "new_file" },
    { SetInputBuffer = "" },
    { SetInputPrompt = "filename: " },
  }
}

-- history
xplr.config.modes.builtin.go_to.key_bindings.on_key.h = {
  help = "history",
  messages = {
    "PopMode",
    {
      BashExec0 = [===[
        PTH=$(cat "${XPLR_PIPE_HISTORY_OUT:?}" | sort -z -u | fzf --read0)
        if [ "$PTH" ]; then
          "$XPLR" -m 'ChangeDirectory: %q' "$PTH"
        fi
      ]===],
    },
  },
}

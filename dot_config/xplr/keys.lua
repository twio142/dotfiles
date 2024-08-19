require("tree-view").setup({
    mode = "switch_layout",
    key = "t",

    -- If you feel slowness, you might want to toggle back to the default view.
    toggle_layout_mode = "default",
    toggle_layout_key = "esc",
    -- Press backspace to close all and back and close
    close_all_and_back_mode = "default",
    close_all_and_back_key = "backspace",
    -- Toggle expansion without entering
    toggle_expansion_mode = "default",
    toggle_expansion_key = "o",
    -- Toggle expansion of all the nodes under pwd
    toggle_expansion_all_mode = "default",
    toggle_expansion_all_key = "O",
    -- Focus on the next visible line, not compatible with up/down action
    focus_next_mode = "default",
    focus_next_key = "down",
    -- Focus on the previous visible line, not compatible with up/down action
    focus_prev_mode = "default",
    focus_prev_key = "up",
    -- Go to the next deep level directory that's open
    goto_next_open_mode = "default",
    goto_next_open_key = ")",
    -- Go to the previous deep level directory that's open
    goto_prev_open_mode = "default",
    goto_prev_open_key = "(",
    -- Whether to display the tree in full screen
    fullscreen = false,
    -- Indent for the branches of the tree
    indent = "  ",
    -- Start xplr with tree view layout
    as_initial_layout = false,
    -- Disables toggling layout.
    as_default_layout = false,
    -- Automatically fallback to this layout for better performance if the
    -- branch contains # of nodes more than the threshold value
    fallback_layout = "Table",
    fallback_threshold = 500,  -- default: nil (disabled)
})

local on_key = xplr.config.modes.builtin.default.key_bindings.on_key

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
on_key["alt-j"] = on_key["}"]
on_key["alt-k"] = on_key["{"]

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
  messages = {
    {
      CallLua = "custom.pasteSelected",
    },
  }
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
  messages = {
    {
      CallLua = "custom.moveSelected",
    },
  }
}

xplr.config.modes.custom.new_file = {
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
    return { "Refresh" }
  end
  xplr.util.shell_execute("touch", { filename })
  return {}
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

on_key["ctrl-v"] = {
  help = "action selected files",
  messages = {
    "PopMode",
    { SwitchModeBuiltin = "selection_ops" },
  }
}

xplr.fn.custom.copy_path = function(ctx)
  local path = ctx.focused_node.absolute_path
  os.execute("echo " .. xplr.util.shell_escape(path) .. " | pbcopy")
  return { { LogSuccess = "Copied path to clipboard: " .. path } }
end

on_key.y = {
  help = "copy file path",
  messages = {
    { CallLuaSilently = "custom.copy_path" },
  }
}

xplr.fn.custom.browse_in_alfred = function(ctx)
  local path = ctx.focused_node.absolute_path
  xplr.util.shell_execute("alfred", { path })
end

on_key.a = {
  help = "browse in alfred",
  messages = {
    { CallLuaSilently = "custom.browse_in_alfred" },
  }
}

xplr.fn.custom.add_to_alfred_buffer = function(ctx)
local args = { "-w", "com.nyako520.syspre", "-t", "buffer", "-a", "-" }
  if #ctx.selection > 0 then
    for _, node in ipairs(ctx.selection) do
      table.insert(args, node.absolute_path)
    end
  else
    table.insert(args, ctx.focused_node.absolute_path)
  end
  xplr.util.shell_execute("altr", args)
end

on_key['='] = {
  help = "add to alfred buffer",
  messages = {
    { CallLuaSilently = "custom.add_to_alfred_buffer" },
  }
}

xplr.fn.custom.cd_in_tmux = function(ctx)
  if os.getenv("TMUX") == nil then
    return { { LogError = "Not in tmux" } }
  end
  local output = xplr.util.shell_execute("tmux", { "display", "-p", "#{pane_current_command} #{client_pid}" }).stdout
  local process, pid = string.match(output, "(%S+) (%d+)")
  local path = ctx.focused_node.absolute_path
  local scpt = os.getenv("XDG_CONFIG_HOME") .. "/tmux/scripts/find_empty_shell.sh"
  xplr.util.shell_execute(scpt, { pid, "lc " .. xplr.util.shell_escape(path) })
  return { "Quit" }
end

on_key.enter = {
  help = "cd in tmux",
  messages = {
    { CallLuaSilently = "custom.cd_in_tmux" },
  }
}

xplr.fn.custom.vim_in_tmux = function(ctx)
  if os.getenv("TMUX") == nil then
    return { { LogError = "Not in tmux" } }
  end
  local output = xplr.util.shell_execute("tmux", { "display", "-p", "#{pane_current_command} #{client_pid}" }).stdout
  local process, pid = string.match(output, "(%S+) (%d+)")
  if process == "xplr" then
    return { { LogError = "xlpr is not running in popup" } }
  end
  local args = { pid }
  if #ctx.selection > 0 then
    for _, node in ipairs(ctx.selection) do
      table.insert(args, xplr.util.shell_escape(node.absolute_path))
    end
  else
    table.insert(args, xplr.util.shell_escape(ctx.focused_node.absolute_path))
  end
  local scpt = os.getenv("XDG_CONFIG_HOME") .. "/tmux/scripts/open_in_vim.sh"
  xplr.util.shell_execute(scpt, args)
  return { "Quit" }
end

on_key.e = {
  help = "open in vim in tmux",
  messages = {
    { CallLuaSilently = "custom.vim_in_tmux" },
  }
}

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

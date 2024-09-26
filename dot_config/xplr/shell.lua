_G.xplr = xplr

xplr.config.modes.custom.run_shell = {
  name = "run shell command",
  key_bindings = {
    on_key = {
      enter = {
        help = "confirm",
        messages = {
          { CallLuaSilently = "custom.run_shell" },
          "PopMode",
        },
      },
      esc = {
        help = "cancel",
        messages = {
          "PopMode",
        },
      },
      ["alt-b"] = {
        messages = {
          { UpdateInputBuffer = "GoToPreviousWord" },
        }
      },
      ["alt-f"] = {
        messages = {
          { UpdateInputBuffer = "GoToNextWord" },
        }
      },
      ["ctrl-w"] = {
        messages = {
          { UpdateInputBuffer = "DeletePreviousWord" },
        }
      },
      ["alt-d"] = {
        messages = {
          { UpdateInputBuffer = "DeleteNextWord" },
        }
      },
      ["alt-k"] = {
        messages = {
          { UpdateInputBuffer = "DeleteTillEnd" },
        }
      },
    },
    default = {
      messages = {
        "UpdateInputBufferFromKey",
      },
    },
  },
}

xplr.fn.custom.shell_prompt = function(ctx)
  local files = {}
  if #ctx.selection > 0 then
    for _, node in ipairs(ctx.selection) do
      table.insert(files, xplr.util.shell_escape(node.absolute_path))
    end
  else
    table.insert(files, xplr.util.shell_escape(ctx.focused_node.absolute_path))
  end
  local input = table.concat(files, " ")
  return {
    { SwitchModeCustom = "run_shell" },
    { SetInputBuffer = " " .. input },
    { SetInputPrompt = "❯ " },
    { UpdateInputBuffer = "GoToStart" }
  }
end

xplr.fn.custom.run_shell = function(ctx)
  local command = ctx.input_buffer
  if command == "" then
    return {}
  end
  return { { BashExec0 = command } }
end

local on_key = xplr.config.modes.builtin.default.key_bindings.on_key
on_key["!"] = {
  help = "run shell command",
  messages = {
    "PopMode",
    { CallLua = "custom.shell_prompt" },
  }
}


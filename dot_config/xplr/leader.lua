_G.xplr = xplr

xplr.config.modes.custom.space = {
  name = "space",
  key_bindings = {
    on_key = {
      l = {
        help = "[l]ogs",
        messages = {
          {
            BashExec = [[
              [ -z "$PAGER" ] && PAGER="less -+F"
              cat -- "${XPLR_PIPE_LOGS_OUT}" | ${PAGER:?} -l log
            ]],
          },
          "PopMode",
        }
      },
      v = {
        help = "action on selected files",
        messages = {
          { CallLuaSilently = "custom.actionOnSelection" },
        }
      },
      x = {
        help = "[x]pm",
        messages = {
          "PopMode",
          { SwitchModeCustom = "xpm" },
        },
      },
      [":"] = {
        help = "shell",
        messages = {
          { Call = { command = os.getenv("SHELL"), args = { "-i" } } },
          "ExplorePwdAsync",
          "PopMode",
        }
      },
    },
    default = {
      messages = { "PopMode" },
    }
  }
}

xplr.config.modes.builtin.default.key_bindings.on_key.space = {
  help = "space leader",
  messages = {
    { SwitchModeCustom = "space" },
  },
}

xplr.config.modes.custom.backslash = {
  name = "leader",
  key_bindings = {
    on_key = {},
    default = {
      messages = { "PopMode" },
    }
  }
}

xplr.config.modes.builtin.default.key_bindings.on_key["\\"] = {
  help = "backslash leader",
  messages = {
    { SwitchModeCustom = "backslash" },
  },
}

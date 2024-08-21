xplr.config.modes.custom.space = {
  name = "space",
  key_bindings = {
    on_key = {
      g = {
        help = "autojump",
        messages = {
          "PopMode",
          { CallLua = "custom.autojump.search" },
        },
      },
      f = {
        help = "fzf",
        messages = {
          "PopMode",
          { CallLua = "custom.fzf.search" },
        },
      },
      v = {
        help = "action on selected files",
        messages = {
          { CallLuaSilently = "custom.actionOnSelection" },
        }
      },
      x = {
        help = "xpm",
        messages = {
          "PopMode",
          { SwitchModeCustom = "xpm" },
        },
      },
      ["/"] = {
        help = "fif",
        messages = {
          "PopMode",
          { CallLua = "custom.fif.search" },
        },
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

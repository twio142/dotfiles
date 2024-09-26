_G.xplr = xplr

xplr.config.modes.builtin.default.key_bindings.on_key.b = {
  help = "[b]ookmark mode",
  messages = {
    { SwitchModeCustom = "bookmark" },
  },
}

xplr.config.modes.custom.bookmark = {
  name = "bookmark",
  key_bindings = {
    on_key = {
      a = {
        help = "[a]dd bookmark",
        messages = {
          {
            BashExecSilently0 = [[
              PTH="${XPLR_FOCUS_PATH:?}"
              if [ -d "${PTH}" ]; then
                PTH="${PTH}"
              elif [ -f "${PTH}" ]; then
                PTH=$(dirname "${PTH}")
              fi
              PTH_ESC=$(printf %q "$PTH")
              if echo "${PTH:?}" >> "${XDG_DATA_HOME}/xplr/bookmarks"; then
                "$XPLR" -m 'LogSuccess: %q' "$PTH_ESC added to bookmarks"
              else
                "$XPLR" -m 'LogError: %q' "Failed to bookmark $PTH_ESC"
              fi
            ]],
          },
          "PopMode",
        },
      },
      b = {
        help = "list bookmarks",
        messages = {
          {
            BashExec0 = [===[
              PTH=$(cat "${XDG_DATA_HOME}/xplr/bookmarks" | fzf --no-sort --preview="fzf-preview {}" --bind="ctrl-x:execute-silent(sd -F {} '' '${XDG_DATA_HOME}/xplr/bookmarks'; sd '\n+' '\n' '${XDG_DATA_HOME}/xplr/bookmarks')+reload(cat '${XDG_DATA_HOME}/xplr/bookmarks')")
              if [ "$PTH" ]; then
                "$XPLR" -m 'ChangeDirectory: %q' "$PTH"
              fi
            ]===],
          },
          "PopMode",
        },
      },
      d = {
        help = "[d]elete bookmark",
        messages = {
          {
            BashExec0 = [[
              PTH=$(cat "${XDG_DATA_HOME}/xplr/bookmarks" | fzf --no-sort)
              sd -F "$PTH" "" "${XDG_DATA_HOME}/xplr/bookmarks"
            ]],
          },
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
  },
}

xplr.config.modes.builtin.default.key_bindings.on_key.b = {
  help = "bookmark mode",
  messages = {
    { SwitchModeCustom = "bookmark" },
  },
}

xplr.config.modes.custom.bookmark = {
  name = "bookmark",
  key_bindings = {
    on_key = {
      a = {
        help = "bookmark dir",
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
              PTH=$(cat "${XDG_DATA_HOME}/xplr/bookmarks" | fzf --no-sort --preview="tree -atrC -L 4 -I .DS_Store -I .git {}" --bind="ctrl-x:execute-silent(sd -F {} '' '${XDG_DATA_HOME}/xplr/bookmarks'; sd '\n+' '\n' '${XDG_DATA_HOME}/xplr/bookmarks')+reload(cat '${XDG_DATA_HOME}/xplr/bookmarks')")
              if [ "$PTH" ]; then
                "$XPLR" -m 'ChangeDirectory: %q' "$PTH"
              fi
            ]===],
          },
          "PopMode",
        },
      },
      d = {
        help = "delete bookmark",
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

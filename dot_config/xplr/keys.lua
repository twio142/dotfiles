_G.xplr = xplr

local on_key = xplr.config.modes.builtin.default.key_bindings.on_key

on_key.c.help = "[c]opy to"
on_key.d.help = "[d]elete"
on_key.f.help = "[f]ilter"
on_key.s.help = "[s]ort"
on_key.g.help = "[g]o to"
on_key.m.help = "[m]ove to"
on_key.t.help = "[t]ree view"

xplr.fn.custom.rename = function(ctx)
  local path = ctx.focused_node.absolute_path
  local filename = xplr.util.basename(path)
  local extname = ctx.focused_node.extension
  extname = extname == "" and "" or "." .. extname
  return {
    "PopMode",
    { SwitchModeBuiltin = "rename" },
    { SetInputBuffer = filename },
    { UpdateInputBuffer = { SetCursor = #filename - #extname } },
  }
end
on_key.r = {
  help = "[r]ename",
  messages = { { CallLua = "custom.rename" } }
}

-- selection
on_key.J = {
  help = "focus next selection",
  messages = { "FocusNextSelection" }
}
on_key.K = {
  help = "focus previous selection",
  messages = { "FocusPreviousSelection" }
}
xplr.fn.custom.actionOnSelection = function(ctx)
  if #ctx.selection == 0 then
    return
  end
  return { "PopMode", { SwitchModeBuiltin = "selection_ops" } }
end
on_key["alt-l"] = {
  help = "action on selected files",
  messages = {
    { CallLuaSilently = "custom.actionOnSelection" },
  }
}
on_key["alt-j"] = {
  help = "toggle selection",
  messages = {
    "ToggleSelection",
    "FocusNext",
  }
}
on_key["alt-k"] = {
  help = "toggle selection",
  messages = {
    "ToggleSelection",
  }
}
on_key.tab = on_key["alt-j"]
xplr.fn.custom.removeLastSelection = function(ctx)
  if #ctx.selection == 0 then
    return
  end
  return { { UnSelectPath = ctx.selection[#ctx.selection].absolute_path } }
end
xplr.fn.custom.reverseSelection = function(ctx)
  local nodes = xplr.util.explore(ctx.pwd)
  local messages = {}
  for _, node in ipairs(nodes) do
    table.insert(messages, { ToggleSelectionByPath = node.absolute_path })
  end
  return messages
end
on_key["alt-h"] = {
  help = "remove last selection",
  messages = {
    { CallLuaSilently = "custom.removeLastSelection" },
  }
}
on_key.backspace = {
  help = "clear selection",
  messages = { "ClearSelection" }
}
on_key["ctrl-a"] = {
  help = "toggle select all",
  messages = { "ToggleSelectAll" }
}
on_key["ctrl-r"] = nil
on_key["ctrl-r"] = {
  help = "reverse selection",
  messages = {
    { CallLuaSilently = "custom.reverseSelection" },
  }
}
xplr.config.modes.builtin.selection_ops.layout = nil
xplr.config.modes.builtin.selection_ops.key_bindings.on_key.l = nil
xplr.config.modes.builtin.selection_ops.key_bindings.on_key.r = xplr.config.modes.builtin.selection_ops.key_bindings.on_key.u
xplr.config.modes.builtin.selection_ops.key_bindings.on_key.u = nil
xplr.config.modes.builtin.action.layout = nil
xplr.config.modes.builtin.action.key_bindings.on_key.v = on_key["alt-l"]
xplr.config.modes.builtin.action.key_bindings.on_key.s = nil
xplr.config.modes.builtin.action.key_bindings.on_key.q = nil
xplr.config.modes.builtin.action.key_bindings.on_key.m = nil
xplr.config.modes.builtin.action.key_bindings.on_key[":"] = xplr.config.modes.builtin.action.key_bindings.on_key["!"]
xplr.config.modes.builtin.action.key_bindings.on_key["!"] = nil
xplr.config.modes.builtin.action.key_bindings.on_key.D = on_key["ctrl-d"]
xplr.config.modes.builtin.action.key_bindings.on_key.P = {
  messages = {
    "PopMode",
    { SwitchModeBuiltin = "edit_permissions" },
    {
      BashExecSilently0 = [===[
        PERM=$(stat -f '%A' -- "${XPLR_FOCUS_PATH:?}")
        "$XPLR" -m 'SetInputBuffer: %q' "${PERM:?}"
      ]===],
    }
  },
  help = "edit [P]ermissions",
}
xplr.config.modes.builtin.action.key_bindings.on_number = nil

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

-- type-to-nav
xplr.config.modes.custom.type_to_nav.key_bindings.on_key.up = on_key.k
xplr.config.modes.custom.type_to_nav.key_bindings.on_key.down = on_key.j
on_key.i = {
  help = 'type to nav',
  messages = { { CallLuaSilently = 'custom.type_to_nav_start' } },
}
on_key.I = {
  help = 'type to select',
  messages = { { CallLuaSilently = 'custom.type_to_nav_start_selecting' } },
}
xplr.config.modes.custom.type_to_nav.key_bindings.on_key.left = {
  help = 'go back',
  messages = { { CallLuaSilently = 'custom.type_to_nav_up' } },
}
xplr.config.modes.custom.type_to_nav.key_bindings.on_key.right = {
  help = 'accept',
  messages = { { CallLuaSilently = 'custom.type_to_nav_accept' } },
}
xplr.config.modes.custom.type_to_nav.key_bindings.on_key['ctrl-h'] = {
  messages = {
    "PopMode",
    { CallLuaSilently = "custom.dual_pane.activate_left_pane" },
    { CallLuaSilently = 'custom.type_to_nav_start' }
  },
}
xplr.config.modes.custom.type_to_nav.key_bindings.on_key['ctrl-l'] = {
  messages = {
    "PopMode",
    { CallLuaSilently = "custom.dual_pane.activate_right_pane" },
    { CallLuaSilently = 'custom.type_to_nav_start' }
  },
}
xplr.config.modes.custom.type_to_nav.key_bindings.on_key.tab = xplr.config.modes.custom.type_to_nav.key_bindings.on_key['ctrl-v']

-- copy, move and softlink selected files
xplr.config.modes.builtin.selection_ops.key_bindings.on_key.c = {
  help = "[c]opy here",
  messages = {
    {
      BashExec0 = [===[
        "$XPLR" -m ExplorePwd
        while IFS= read -r -d '' PTH; do
          PTH_ESC=$(printf %q "$PTH")
          BASENAME=$(basename -- "$PTH")
          BASENAME_ESC=$(printf %q "$BASENAME")
          if [ -e "$BASENAME" ]; then
            echo
            echo "$BASENAME_ESC exists, do you want to overwrite it?"
            read -n 1 -p "[y]es, [n]o, [s]kip: " ANS < /dev/tty
            case "$ANS" in
              [yY]*)
                ;;
              [nN]*)
                echo
                read -p "Enter new name: " BASENAME < /dev/tty
                BASENAME_ESC=$(printf %q "$BASENAME")
                ;;
              *)
                continue
                ;;
            esac
          fi
          if err=$(cp -aR -- "${PTH:?}" "./${BASENAME:?}" 2>&1); then
            "$XPLR" -m 'LogSuccess: %q' "$PTH_ESC copied to $BASENAME_ESC"
            "$XPLR" -m ClearSelection
            "$XPLR" -m 'FocusPath: %q' "$BASENAME"
          else
            "$XPLR" -m 'LogError: %q' "$err"
          fi
        done < "${XPLR_PIPE_SELECTION_OUT:?}"
      ]===],
    },
    "PopMode",
  }
}

xplr.config.modes.builtin.selection_ops.key_bindings.on_key.m.help = "[m]ove here"
xplr.config.modes.builtin.selection_ops.key_bindings.on_key.m.messages = {
  {
    BashExec0 = [===[
      "$XPLR" -m ExplorePwd
      while IFS= read -r -d '' PTH; do
        PTH_ESC=$(printf %q "$PTH")
        BASENAME=$(basename -- "$PTH")
        BASENAME_ESC=$(printf %q "$BASENAME")
        if [ -e "$BASENAME" ]; then
          echo
          echo "$BASENAME_ESC exists, do you want to overwrite it?"
          read -n 1 -p "[y]es, [n]o, [s]kip: " ANS < /dev/tty
          case "$ANS" in
            [yY]*)
              ;;
            [nN]*)
              echo
              read -p "Enter new name: " BASENAME < /dev/tty
              BASENAME_ESC=$(printf %q "$BASENAME")
              ;;
            *)
              continue
              ;;
          esac
        fi
        if err=$(mv -- "${PTH:?}" "./${BASENAME:?}" 2>&1); then
          "$XPLR" -m 'LogSuccess: %q' "$PTH_ESC moved to $BASENAME_ESC"
          "$XPLR" -m 'FocusPath: %q' "$BASENAME"
          "$XPLR" -m ClearSelection
        else
          "$XPLR" -m 'LogError: %q' "$err"
        fi
      done < "${XPLR_PIPE_SELECTION_OUT:?}"
    ]===],
  },
  "PopMode",
}

xplr.config.modes.builtin.selection_ops.key_bindings.on_key.s.help = "[s]oftlink here"
xplr.config.modes.builtin.selection_ops.key_bindings.on_key.s.messages = {
  {
    BashExec0 = [===[
      "$XPLR" -m ExplorePwd
      while IFS= read -r -d '' PTH; do
        PTH_ESC=$(printf %q "$PTH")
        BASENAME=$(basename -- "$PTH")
        BASENAME_ESC=$(printf %q "$BASENAME")
        if [ -e "$BASENAME" ]; then
          echo
          echo "$BASENAME_ESC exists, do you want to overwrite it?"
          read -n 1 -p "[y]es, [n]o, [s]kip: " ANS < /dev/tty
          case "$ANS" in
            [yY]*)
              ;;
            [nN]*)
              echo
              read -p "Enter new name: " BASENAME < /dev/tty
              BASENAME_ESC=$(printf %q "$BASENAME")
              ;;
            *)
              continue
              ;;
          esac
        fi
        if err=$(ln -sf -- "${PTH:?}" "./${BASENAME:?}" 2>&1); then
          "$XPLR" -m 'LogSuccess: %q' "$PTH_ESC softlinked as $BASENAME_ESC"
          "$XPLR" -m 'FocusPath: %q' "$BASENAME"
          "$XPLR" -m ClearSelection
        else
          "$XPLR" -m 'LogError: %q' "$err"
        fi
      done < "${XPLR_PIPE_SELECTION_OUT:?}"
    ]===],
  },
  "PopMode",
}

xplr.config.modes.builtin.selection_ops.key_bindings.on_key.h.help = "[h]ardlink here"

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
  local filename = ctx.input_buffer:match("^%s*(.-)%s*$")
  if filename == "" then
    return {}
  else
    filename = ctx.pwd .. "/" .. filename
  end
  if xplr.util.exists(filename) then
    return { LogError = "File already exists" }
  end
  local r
  if string.sub(filename, -1) == '/' then
    r = xplr.util.shell_execute("mkdir", { "-p", filename })
  else
    r = xplr.util.shell_execute("touch", { filename })
  end
  if r.code ~= 0 then
    return { LogError = r.stderr }
  end
  return { FocusPath = filename }
end

on_key.N = {
  help = "[N]ew file",
  messages = {
    "PopMode",
    { SwitchModeCustom = "new_file" },
    { SetInputBuffer = "" },
    { SetInputPrompt = "❯ filename: " },
  }
}
xplr.config.modes.builtin.action.key_bindings.on_key.c = nil

-- delete selected files
xplr.config.modes.builtin.delete.layout = nil
xplr.config.modes.builtin.delete.key_bindings.on_key.d = {
  help = "[d]elete",
  messages = {
    {
      BashExecSilently0 = [===[
        while IFS= read -r -d "" line; do
          if err=$(trash -F "${line:?}"); then
            "$XPLR" -m "LogSuccess: %q" "File trashed: $line"
          else
            "$XPLR" -m "LogError: %q" "$err"
          fi
        done < "${XPLR_PIPE_RESULT_OUT:?}"
        "$XPLR" -m ExplorePwdAsync
      ]===],
    },
    "PopMode",
  },
}

xplr.config.modes.builtin.delete.key_bindings.on_key.D.help = "Force [D]elete"
xplr.config.modes.builtin.delete.key_bindings.on_key.E = {
  help = "[E]mpty trash",
  messages = {
    {
      BashExecSilently0 = [===[
        if err=$(trash -e -y); then
          "$XPLR" -m "LogSuccess: %q" "Trash emptied"
        else
          "$XPLR" -m "LogError: %q" "$err"
        fi
      ]===],
    },
    "PopMode",
  },
}

-- go to
xplr.config.modes.builtin.go_to.layout = nil
xplr.config.modes.builtin.go_to.key_bindings.on_key.f.help = "[f]ollow symlink"
xplr.config.modes.builtin.go_to.key_bindings.on_key.space = xplr.config.modes.builtin.go_to.key_bindings.on_key.p
xplr.config.modes.builtin.go_to.key_bindings.on_key.space.help = "enter path"
xplr.config.modes.builtin.go_to.key_bindings.on_key.p = nil
xplr.config.modes.builtin.go_to.key_bindings.on_key.r = {
  help = "[r]ecent",
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
xplr.config.modes.builtin.action.key_bindings.on_key.e.help = "[e]dit file"
xplr.config.modes.builtin.action.key_bindings.on_key.p.help = "edit [p]ermissions"
xplr.config.modes.builtin.action.key_bindings.on_key.D.help = "[D]uplicate as"
xplr.config.modes.builtin.action.key_bindings.on_key.O = xplr.config.modes.builtin.go_to.key_bindings.on_key.x
xplr.config.modes.builtin.action.key_bindings.on_key.O.help = "[O]pen with gui"
xplr.config.modes.builtin.action.key_bindings.on_key.l = nil

xplr.config.modes.builtin.go_to.key_bindings.on_key.x = nil
on_key["["] = {
  help = "last visited path",
  messages = {
    "PopMode",
    "LastVisitedPath",
  }
}
on_key["]"] = {
  help = "next visited path",
  messages = {
    "PopMode",
    "NextVisitedPath",
  }
}
xplr.config.modes.builtin.go_to.key_bindings.on_key["["] = {
  help = "last visited path",
  messages = {
    "PopMode",
    "LastVisitedPath",
  }
}
xplr.config.modes.builtin.go_to.key_bindings.on_key["]"] = {
  help = "next visited path",
  messages = {
    "PopMode",
    "NextVisitedPath",
  }
}

-- sort
local s_key = xplr.config.modes.builtin.sort.key_bindings.on_key
s_key.down = on_key.j
s_key.up = on_key.k
s_key.i = s_key.m
s_key.I = s_key.M
s_key.m = s_key.l
s_key.M = s_key.L
s_key.t = s_key.n
s_key.T = s_key.N
s_key.a = s_key.r
s_key.A = s_key.R
s_key.l = nil
s_key.L = nil
s_key.n = nil
s_key.N = nil
s_key.r = nil
s_key.R = nil
s_key.esc = { messages = { "PopMode" } }
table.insert(on_key.s.messages, { BufferInput = "[a]lphabet / [c]time / [e]xt / [m]time / [s]ize / [t]ype" })

-- filter
local f_key = xplr.config.modes.builtin.filter.key_bindings.on_key
f_key.down = on_key.j
f_key.up = on_key.k
table.insert(on_key.f.messages, { BufferInput = "[r]egex" })

-- help
local help = xplr.config.general.global_key_bindings.on_key["f1"]
help.messages = {
  {
    BashExec = [===[
      [ -z "$PAGER" ] && PAGER="less -+F"
      cat -- "${XPLR_PIPE_GLOBAL_HELP_MENU_OUT}" | ${PAGER:?} -l md
    ]===],
  }
}

xplr.config.general.global_key_bindings.on_key["?"] = help

xplr.config.modes.custom.xpm.key_bindings.on_key.x = xplr.config.modes.custom.xpm.key_bindings.on_key.c
xplr.config.modes.custom.xpm.key_bindings.on_key.c = nil

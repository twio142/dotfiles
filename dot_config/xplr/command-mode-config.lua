-- Assuming you have installed and setup the plugin

local m = require("command-mode")

-- Setup with default settings
-- m.setup()

-- Type `:hello-lua` and press enter to know your location
-- local hello_lua = m.cmd("hello-lua", "Enter name and know location")(function(app)
--   print("What's your name?")
--
--   local name = io.read()
--   local greeting = "Hello " .. name .. "!"
--   local message = greeting .. " You are inside " .. app.pwd
--
--   return {
--     { LogSuccess = message },
--   }
-- end)

-- Type `:hello-bash` and press enter to know your location
-- local hello_bash = m.silent_cmd("hello-bash", "Enter name and know location")(
--   m.BashExec [===[
--     echo "What's your name?"
--
--     read name
--     greeting="Hello $name!"
--     message="$greeting You are inside $PWD"
--
--     "$XPLR" -m "LogSuccess: %q" "$message"
--   ]===]
-- )

local open_in_vscode = m.silent_cmd("vscode", "Open in VSCode")(
  m.BashExec [===[
    code "$PWD"
    sleep 1
    code -g "${XPLR_FOCUS_PATH:?}"
  ]===]
)

local compare = m.cmd("compare", "Compare files")(function(ctx)
  if #ctx.selection ~= 2 then
    return { { LogError = "Please select exactly 2 files to compare" } }
  end
  local paths = xplr.util.shell_escape(ctx.selection[1].absolute_path) .. " " .. xplr.util.shell_escape(ctx.selection[2].absolute_path)
  return { { BashExec = [[ delta --$(~/bin/background) --navigate --tabs=2 --line-numbers --side-by-side --paging=always ]] .. paths } }
end)

-- Bind `:hello-lua` to key `h`
-- hello_lua.bind("default", "h")
-- or xplr.config.modes.builtin.default.key_bindings.on_key.h = hello_lua.action

-- Bind `:hello-bash` to key `H`
-- hello_bash.bind(xplr.config.modes.builtin.default, "H")
-- or xplr.config.modes.builtin.default.key_bindings.on_key.H = hello_bash.action

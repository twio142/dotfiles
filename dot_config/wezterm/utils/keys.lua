local wt_action = require("wezterm").action
-- local h = require("utils/helpers")
local M = {}

M.multiple_actions = function(keys)
  local actions = {}
  for key in keys:gmatch(".") do
    table.insert(actions, wt_action.SendKey({ key = key }))
  end
  table.insert(actions, wt_action.SendKey({ key = "\n" }))
  return wt_action.Multiple(actions)
end

M.key_table = function(mods, key, action)
  action = type(action) == "string" and wt_action[action] or action
  return {
    mods = mods,
    key = key,
    action = action,
  }
end

M.cmd_key = function(key, action)
  return M.key_table("CMD", key, action)
end

M.cmd_ctrl_key = function(key, action)
  return M.key_table("CMD|CTRL", key, action)
end

M.cmd_shift_key = function(key, action)
  return M.key_table("CMD|SHIFT", key, action)
end

M.cmd_to_tmux_prefix = function(key, tmux_key)
  return M.cmd_key(
    key,
    wt_action.Multiple({
      wt_action.SendKey({ mods = "CTRL", key = " " }),
      wt_action.SendKey({ key = tmux_key }),
    })
  )
end

M.ctrl_to_tmux_prefix = function(key, tmux_key)
  return M.key_table(
    "CTRL",
    key,
    wt_action.Multiple({
      wt_action.SendKey({ mods = "CTRL", key = " " }),
      wt_action.SendKey({ key = tmux_key }),
    })
  )
end

M.opt_key = function(key, action)
  return M.key_table("OPT", key, action)
end

return M

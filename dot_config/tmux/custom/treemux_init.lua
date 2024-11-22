---@diagnostic disable: undefined-global
-- Neovim init.lua
-- nvim-tree recommends disabling netrw, VIM's built-in file explorer
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Remove the white status bar below
vim.o.laststatus = 0

-- True colour support
vim.o.termguicolors = true

-- lazy.nvim plugin manager
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
vim.uv.fs_stat(lazypath, function(err)
  if err then
    vim.fn.system {
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", -- latest stable release
      lazypath,
    }
  end
end)
vim.opt.rtp:prepend(lazypath)

vim.env.PATH = vim.env.PATH .. ':' .. vim.fn.expand('~/.local/bin')

local function escape(str)
  return '"' .. vim.fn.escape(str, '"!$\\`') .. '"'
end

local function treemux_open()
  local api = require "nvim-tree.api"
  local node = api.tree.get_node_under_cursor()
  if node.type == "directory" then
    api.node.open.edit()
    return
  end
  if node.type == "link" then
    local stat = vim.loop.fs_stat(node.link_to)
    if stat and stat.type == "directory" then
      api.node.open.edit()
      return
    end
  end
  local pane = "{last}"
  local p = vim.fn.system("tmux display -p '#{pane_index}'")
  if vim.v.count > 0 and vim.v.count ~= tonumber(p) then
    pane = tostring(vim.v.count)
  end
  local result = vim.fn.system('tmux display -p -t "'..pane..'" "#{pane_current_command} #{pane_pid}"')
  vim.fn.jobstart({ 'tmux', 'selectp', '-t', pane })
  local cmd, pid = result:match("^(%S+) (%d+)")
  local path = node.absolute_path or vim.fn.getcwd()
  if cmd == "nvim" then
    local command = 'pid=' .. pid .. [[;
    until (ps -o command= -p $pid | grep -Eq "^nvim --embed"); do
      pid=$(pgrep -P $pid 2> /dev/null)
      [ -z "$pid" ] && exit
    done
    /opt/homebrew/bin/fd "nvim\.$pid.*" $TMPDIR --type s ]]
    local socket = vim.fn.system(command):gsub("\n", "")
    if socket ~= "" then
      vim.fn.jobstart({"nvim", "--server", socket, "--remote", path})
      return
    end
  end
  path = "vim "..escape(path)
  if cmd == "zsh" then
    vim.fn.jobstart({"tmux", "send", path, "Enter"})
    return
  end
  vim.fn.jobstart({"tmux", "splitw", "-v", ";", "send-keys", path, "Enter"})
end

local function system_open()
  local api = require "nvim-tree.api"
  local path = api.tree.get_node_under_cursor().absolute_path or vim.fn.getcwd()
  vim.ui.open(path)
end

-- @param action: "send", "run", "lc", "vim"
  -- "send": prompt text to tmux pane
  -- "run": prompt text to tmux pane and enter
  -- "lc": run `lc` on the path in tmux pane
  -- "vim": open the path in vim
-- @param split: "h", "v"
  -- "h": horizontal split
  -- "v": vertical split
local function treemux_send(action, split, new_window)
  local api = require "nvim-tree.api"
  local tx = {"tmux", "selectp", "-t"}
  local cmd = ''
  if action == "send" or action == "run" then
    local mode = vim.api.nvim_get_mode().mode
    local text = ''
    if mode == "n" then
      text = api.tree.get_node_under_cursor().absolute_path or vim.fn.getcwd()
    else
      vim.cmd 'normal! "oy'
      text = vim.fn.getreg 'o'
    end
    vim.fn.system('printf ' .. escape(text) .. ' | tmux loadb -')
  elseif new_window and action == "lc" then
    local path
    local node = api.tree.get_node_under_cursor()
    if not node then
      path = vim.fn.getcwd()
    elseif node.type == "directory" then
      path = node.absolute_path
    else
      path = vim.fn.fnamemodify(node.absolute_path, ":h")
    end
    tx = {"tmux", "new-window", "-c", path}
  else
    local path = api.tree.get_node_under_cursor().absolute_path or vim.fn.getcwd()
    cmd = action.." "..escape(path)
  end
  local p = vim.fn.system("tmux display -p '#{pane_index}'")
  if vim.v.count > 0 and vim.v.count ~= tonumber(p) then
    table.insert(tx, tostring(vim.v.count))
  else
    table.insert(tx, "{last}")
  end
  if action == "send" or action == "run" then
    vim.list_extend(tx, { ";", "paste-buffer", "-d" })
  elseif split == "h" or split == "v" then
    vim.list_extend(tx, { ";", "split-window", "-"..split })
  elseif new_window then
    vim.list_extend(tx, { ";", "new-window" })
  end
  if #cmd > 0 then
    vim.list_extend(tx, { ";", "send-keys", cmd, "Enter" })
  elseif action == "run" then
    vim.list_extend(tx, { ";", "send-keys", "Enter", ";", "select-pane", "-l" })
  end
  vim.fn.jobstart(tx)
end

local function copy_path(b)
  local api = require "nvim-tree.api"
  local mode = vim.api.nvim_get_mode().mode
  local text = ''
  if mode == "n" then
    text = api.tree.get_node_under_cursor().absolute_path or vim.fn.getcwd()
  else
    vim.cmd 'normal! "oy'
    text = vim.fn.getreg 'o'
  end
  text = escape(text)
  local cmd = b and "tmux loadb -" or "pbcopy"
  local msg = b and "tmux buffer" or "clipboard"
  vim.fn.system('printf ' .. text .. ' | ' .. cmd)
  vim.notify("Copied to "..msg .."!")
end

local function show_in_alfred()
  local api = require "nvim-tree.api"
  local path = api.tree.get_node_under_cursor().absolute_path or vim.fn.getcwd()
  vim.fn.jobstart({vim.fn.exepath("alfred"), path})
end

local function add_to_alfred_buffer()
  local api = require "nvim-tree.api"
  local args = {vim.fn.exepath("altr"), "-w", "com.nyako520.syspre", "-t", "buffer", "-a", "-" }
  if #api.marks.list() > 0 then
    vim.list_extend(args, vim.tbl_map(function(node)
      return node.absolute_path
    end, api.marks.list()))
    vim.fn.jobstart(args)
    api.marks.clear()
  else
    local path = api.tree.get_node_under_cursor().absolute_path or vim.fn.getcwd()
    table.insert(args, path)
    vim.fn.jobstart(args)
  end
end

local function preview()
  local api = require "nvim-tree.api"
  local path = api.tree.get_node_under_cursor().absolute_path or vim.fn.getcwd()
  vim.fn.jobstart({"tmux", "popup", "-w", "75%", "-h", "90%", "-x", "30%", "-y", "54%", "-e", "TMUX_POPUP=1", vim.fn.exepath("fzf-preview"), path})
end

local function fzf()
  local root = vim.fn.shellescape(vim.fn.getcwd())
  local path = vim.fn.system('fd . '..root..' --type d | fzf --tmux center,75%,90%')
  if path ~= "" then
    vim.cmd("edit " .. path)
  end
end

local function autojump()
  local _z = ":reload:zoxide query {q} -l --exclude '${PWD}' | awk '{ if (!seen[tolower()]++) print }' || true"
  vim.fn.jobstart({"fzf", "--bind", "start".._z, "--bind", "change".._z, "--disabled", "--preview", "fzf-preview {}", "--tmux", "center,75%,90%"}, {
    on_stdout = function(_, data, _)
      if data and #data[1] > 0 then
        vim.cmd("edit " .. data[1])
      end
    end
  })
end

local function prev_pane_path()
  local result = vim.fn.system("tmux lsp -F '#{pane_last} #{pane_current_path}'")
  for line in result:gmatch("[^\r\n]+") do
    local last, path = line:match("^([01]) (.+)")
    if last == "1" then
      return path
    end
  end
end

local function nvim_tree_on_attach(bufnr)
  local api = require "nvim-tree.api"

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  api.config.mappings.default_on_attach(bufnr)

  vim.keymap.set("n", "u", api.tree.change_root_to_node, opts "Dir up")
  vim.keymap.set("n", "<CR>", function() treemux_send("lc") end, opts "Open dir")
  vim.keymap.del("n", "e", { buffer = bufnr })
  vim.keymap.set("n", "e<CR>", function() treemux_send("vim") end, opts "Edit file")
  vim.keymap.set("n", "t", function() treemux_send("lc","",true) end, opts "Open in new window")
  vim.keymap.set("n", "<2-LeftMouse>", treemux_open, opts "Open in treemux")
  vim.keymap.set("n", "o", treemux_open, opts "Open in treemux")
  vim.keymap.set("n", "l", treemux_open, opts "Open in treemux")

  vim.keymap.del("n", "y", { buffer = bufnr })
  vim.keymap.set({"n", "x"}, "y", function() copy_path() end, opts "Copy path")
  vim.keymap.set({"n", "x"}, "\\y", function() copy_path(1) end, opts "Copy path to buffer")
  vim.keymap.del("n", "-", { buffer = bufnr })
  vim.keymap.set({"n", "x"}, "-", function() treemux_send("run") end, opts "Execute text in pane")
  vim.keymap.set({"n", "x"}, "_", function() treemux_send("send") end, opts "Send text to pane")
  vim.keymap.set("n", "a", show_in_alfred, opts "Show in Alfred")
  vim.keymap.set("n", "=", add_to_alfred_buffer, opts "Add to Alfred buffer")
  vim.keymap.del("n", "q", { buffer = bufnr })
  vim.keymap.set("n", "q", function()
    vim.cmd "quitall!"
  end, opts "Quit nvim tree")
  vim.keymap.set("n", "<F1>", function()
    vim.cmd "quitall!"
  end, opts "Quit nvim tree")
  vim.keymap.set("n", "h", api.node.navigate.parent, opts "Parent directory")
  vim.keymap.set("n", "<C-v>", function() treemux_send("lc","v") end, opts "Open in new pane")
  vim.keymap.set("n", "<C-s>", function() treemux_send("lc","h") end, opts "Open in new vertical pane")
  vim.keymap.set("n", "es", function() treemux_send("vim","v") end, opts "Edit file in new pane")
  vim.keymap.set("n", "ev", function() treemux_send("vim","h") end, opts "Edit file in new vertical pane")
  vim.keymap.set("n", "et", function() treemux_send("vim","",true) end, opts "Edit file in new window")
  vim.keymap.del("n", ".", { buffer = bufnr })
  vim.keymap.set("n", ".", api.tree.toggle_hidden_filter, opts "Toggle hidden files")
  vim.keymap.set("n", "?", api.tree.toggle_help, opts "Toggle help")
  vim.keymap.del("n", ">", { buffer = bufnr })
  vim.keymap.set("n", ">", api.node.run.cmd, opts "Run command")
  vim.keymap.set("n", "C", api.tree.change_root_to_node, opts "Change root to node")
  vim.keymap.set("n", "N", api.fs.create, opts "New file / folder")
  vim.keymap.del("n", "P", { buffer = bufnr })
  vim.keymap.set("n", "P", preview, opts "Preview file")
  vim.keymap.set("n", ",", function()
    api.tree.find_file({ buf = prev_pane_path(), update_root = true, focus = true })
  end, opts "Relocate working dir")
  vim.keymap.set("n", "\\f", fzf, opts "FZF")
  vim.keymap.set("n", "\\g", autojump, opts "Autojump")
  vim.keymap.set("n", "{", api.tree.collapse_all, opts "Collapse all")
  vim.keymap.set("n", "}", api.tree.expand_all, opts "Expand all")
  vim.keymap.del("n", "<C-r>", { buffer = bufnr })
  vim.keymap.set("n", "<C-r>", api.tree.reload, opts "Refresh")
  vim.keymap.del("n", "R", { buffer = bufnr })
  vim.keymap.set("n", "R", api.fs.rename_sub, opts "Rename")
  vim.keymap.set("n", "B", api.tree.toggle_no_bookmark_filter, opts "Toggle bookmark filter")

  vim.keymap.set("n", "<C-d>", ":qa!<CR>", opts "Exit nvim tree")

  vim.keymap.set("n", "<C-k>", "", { buffer = bufnr })
  vim.keymap.del("n", "<C-k>", { buffer = bufnr })
  vim.keymap.del("n", "O", { buffer = bufnr })
  vim.keymap.set("n", "O", system_open, opts "Open in system")
  vim.keymap.del("n", "<Tab>", { buffer = bufnr })

  vim.keymap.set("n", "<Esc>", function()
    vim.cmd [[ set nohlsearch ]]
  end, opts "No highlight")

  api.tree.find_file({ buf = prev_pane_path(), update_root = true, focus = true })
end

require("lazy").setup {
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    init = function()
      vim.cmd.colorscheme 'tokyonight-night'
      vim.cmd.hi 'Comment gui=none'
    end,
    opts = {
      style = "night",
      light_style = "day",
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      day_brightness = 0.35,
    }
  },
  "nvim-tree/nvim-web-devicons",
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      local nvim_tree = require "nvim-tree"

      nvim_tree.setup {
        on_attach = nvim_tree_on_attach,
        update_focused_file = {
          enable = true,
          update_cwd = true,
        },
        renderer = {
          --root_folder_modifier = ":t",
          icons = {
            glyphs = {
              default = "",
              symlink = "",
              folder = {
                arrow_open = "",
                arrow_closed = "",
                default = "",
                open = "",
                empty = "",
                empty_open = "",
                symlink = "",
                symlink_open = "",
              },
              git = {
                unstaged = "*",
                staged = "󰐕",
                unmerged = "",
                renamed = "󰁕",
                untracked = "",
                deleted = "✖",
                ignored = "",
              },
            },
            git_placement = "right_align",
            bookmarks_placement = "before",
          },
        },
        view = {
          width = 20,
          side = "left",
          signcolumn = "no",
        },
        filters = {
          custom = { "^\\.DS_Store$" },
          git_ignored = false,
        },
        sort = {
          folders_first = true,
          sorter = "modification_time",
        }
      }
    end,
  },
  {
    "aserowy/tmux.nvim",
    config = function()
      -- Navigate tmux, and nvim splits.
      -- Sync nvim buffer with tmux buffer.
      require("tmux").setup {
        copy_sync = {
          enable = true,
          sync_clipboard = false,
          sync_registers = true,
        },
        resize = {
          enable_default_keybindings = false,
        },
      }
    end,
  },
}

local bg = vim.fn.exepath("background") == "" and "dark" or vim.fn.system(vim.fn.exepath("background"))
if bg == 'light' or bg == 'dark' then
  vim.opt.background = bg
end
vim.o.cursorline = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.fillchars = "eob: "

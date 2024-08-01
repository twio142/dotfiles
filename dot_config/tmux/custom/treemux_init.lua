-- Neovim init.lua
-- nvim-tree recommends disabling netrw, VIM's built-in file explorer
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.python3_host_prog = os.getenv "HOME" .. '/miniconda3/envs/py3/bin/python'

-- Remove the white status bar below
vim.o.laststatus = 0
vim.o.guifont = "FiraCode Nerd Font:h11"

-- True colour support
vim.o.termguicolors = true

-- lazy.nvim plugin manager
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

local function escape(str)
  return '"' .. vim.fn.escape(str, '"!$\\`') .. '"' 
end

local function treemux_open(v, p)
  local api = require "nvim-tree.api"
  local path = api.tree.get_node_under_cursor().absolute_path
  if not path then
    return
  end
  path = escape(path)
  os.execute('tmux select-pane -l')
  local cmd = "lc "..path
  if v then
    cmd = "vim "..path
  end
  if p == "h" or p == "v" then
    os.execute('tmux split-window -'..p)
  end
  os.execute('tmux send-keys "'..cmd..'" Enter')
end

local function copy_path(b)
  local api = require "nvim-tree.api"
  local path = api.tree.get_node_under_cursor().absolute_path
  if not path then
    return
  end
  path = escape(path)
  if b then
    os.execute('echo ' .. path .. ' | tmux load-buffer -')
    vim.cmd("echo 'Copied to tmux buffer!' | redraw!")
  else
    os.execute('echo ' .. path .. ' | pbcopy')
    vim.cmd("echo 'Copied to clipboard!' | redraw!")
  end
end

local function show_in_alfred()
  local api = require "nvim-tree.api"
  local path = api.tree.get_node_under_cursor().absolute_path
  if not path then
    return
  end
  path = escape(path)
  os.execute("~/bin/alfred " .. path)
end

local function preview()
  local api = require "nvim-tree.api"
  local path = api.tree.get_node_under_cursor().absolute_path
  local type = api.tree.get_node_under_cursor().type
  if not path or type == "directory" then
    return
  end
  path = vim.fn.shellescape(path)
  os.execute('tmux popup -w 75% -h 90% -x 30% -y 54% -E "bat -n --color=always '..path..'"')
end

local function fzf()
  local api = require "nvim-tree.api"
  local tmpFile = os.tmpname()
  local root = vim.fn.shellescape(vim.fn.getcwd())
  os.execute('tmux popup -w 75% -h 90% -x 30% -y 54% -E \'find "'..root..'" -type d | fzf > '..tmpFile.."'")
  local handle = io.open(tmpFile, "r")
  local path = handle:read("*a")
  handle:close()
  os.remove(tmpFile)
  if path ~= "" then
    vim.cmd("edit " .. path)
    -- api.tree.change_root(path)
  end
end

local function prev_pane_path()
  local handle = io.popen("tmux list-panes -F '#{pane_last} #{pane_current_path}'")
  local result = handle:read('*a')
  handle:close()
  for line in result:gmatch("[^\r\n]+") do
    local last, path = line:match("^([01]) (.+)")
    if last == "1" then
      return path
    end
  end
end

local function nvim_tree_on_attach(bufnr)
  local api = require "nvim-tree.api"
  local nt_remote = require "nvim_tree_remote"

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  api.config.mappings.default_on_attach(bufnr)

  vim.keymap.set("n", "u", api.tree.change_root_to_node, opts "Dir up")
  vim.keymap.set("n", "<F1>", api.node.show_info_popup, opts "Show info popup")
  vim.keymap.set("n", "l", nt_remote.tabnew, opts "Open in treemux")
  vim.keymap.set("n", "<CR>", function() treemux_open() end, opts "Open dir in tmux")
  vim.keymap.set("n", "v<CR>", function() treemux_open(1) end, opts "Open in vim")
  vim.keymap.set("n", "<2-LeftMouse>", nt_remote.tabnew, opts "Open in treemux")
  -- vim.keymap.set("n", "h", api.tree.close, opts "Close node")
  -- vim.keymap.set("n", "v", nt_remote.vsplit, opts "Vsplit in treemux")
  -- vim.keymap.set("n", "<C-v>", nt_remote.vsplit, opts "Vsplit in treemux")
  -- vim.keymap.set("n", "<C-x>", nt_remote.split, opts "Split in treemux")
  vim.keymap.set("n", "o", nt_remote.tabnew, opts "Open in treemux")

  vim.keymap.del("n", "y", { buffer = bufnr })
  vim.keymap.set("n", "y", function() copy_path() end, opts "Copy path")
  vim.keymap.del("n", "Y", { buffer = bufnr })
  vim.keymap.set("n", "Y", function() copy_path(1) end, opts "Copy path to buffer")
  vim.keymap.set("n", "a", show_in_alfred, opts "Show in Alfred")
  vim.keymap.del("n", "q", { buffer = bufnr })
  vim.keymap.set("n", "q", function()
    vim.cmd "quitall!"
  end, opts "Quit nvim tree")
  vim.keymap.set("n", "i", function() treemux_open(nil,'v') end, opts "Open in new pane")
  vim.keymap.set("n", "vi", function() treemux_open(1,'v') end, opts "Open in vim in new pane")
  vim.keymap.set("n", "s", function() treemux_open(nil,'h') end, opts "Open in new vertical pane")
  vim.keymap.set("n", "vs", function() treemux_open(1,'h') end, opts "Open in vim in new vertical pane")
  vim.keymap.del("n", ".", { buffer = bufnr })
  vim.keymap.set("n", ".", api.tree.toggle_hidden_filter, opts "Toggle hidden files")
  vim.keymap.set("n", "?", api.tree.toggle_help, opts "Toggle help")
  vim.keymap.del("n", ">", { buffer = bufnr })
  vim.keymap.set("n", ">", api.node.run.cmd, opts "Run command")
  vim.keymap.set("n", "C", api.tree.change_root_to_node, opts "Change root to node")
  vim.keymap.set("n", "N", api.fs.create, opts "New file / folder")
  vim.keymap.del("n", "<Tab>", { buffer = bufnr })
  vim.keymap.set("n", "<Tab>", preview, opts "Preview file")
  vim.keymap.set("n", ",", function()
    api.tree.find_file({ buf = prev_pane_path(), update_root = true, focus = true })
  end, opts "Find file in tmux")
  vim.keymap.set("n", "<C-f>", fzf, opts "FZF")
  vim.keymap.set("n", "{", api.tree.collapse_all, opts "Collapse all")
  vim.keymap.set("n", "}", api.tree.expand_all, opts "Expand all")
  vim.keymap.del("n", "<C-r>", { buffer = bufnr })
  vim.keymap.set("n", "<C-r>", api.tree.reload, opts "Refresh")
  vim.keymap.del("n", "R", { buffer = bufnr })
  vim.keymap.set("n", "R", api.fs.rename_sub, opts "Refresh")

  vim.keymap.set("n", "<C-d>", ":qa!<CR>", opts "Exit nvim tree")

  vim.keymap.set("n", "-", "", { buffer = bufnr })
  vim.keymap.del("n", "-", { buffer = bufnr })
  vim.keymap.set("n", "<C-k>", "", { buffer = bufnr })
  vim.keymap.del("n", "<C-k>", { buffer = bufnr })
  vim.keymap.set("n", "O", "", { buffer = bufnr })
  vim.keymap.del("n", "O", { buffer = bufnr })

  api.tree.find_file({ buf = prev_pane_path(), update_root = true, focus = true }) 
end

require("lazy").setup {
  {
    "kiyoon/tmuxsend.vim",
    keys = {
      { "-", "<Plug>(tmuxsend-smart)", mode = { "n", "x" } },
      { "_", "<Plug>(tmuxsend-plain)", mode = { "n", "x" } },
      { "<space>-", "<Plug>(tmuxsend-uid-smart)", mode = { "n", "x" } },
      { "<space>_", "<Plug>(tmuxsend-uid-plain)", mode = { "n", "x" } },
      { "<C-_>", "<Plug>(tmuxsend-tmuxbuffer)", mode = { "n", "x" } },
    },
  },
  "kiyoon/nvim-tree-remote.nvim",
  "rakr/vim-one",
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
                empty_open = "",
                symlink = "",
                symlink_open = "",
              },
              git = {
                unstaged = "",
                staged = "S",
                unmerged = "",
                renamed = "➜",
                untracked = "U",
                deleted = "",
                ignored = "◌",
              },
            },
          },
        },
        diagnostics = {
          enable = true,
          show_on_dirs = true,
          icons = {
            hint = "",
            info = "",
            warning = "",
            error = "",
          },
        },
        view = {
          width = 24,
          side = "left",
        },
        filters = {
          custom = { ".git" },
        },
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

local function custom_one()
  if vim.api.nvim_get_option('background') == 'dark' then
    vim.cmd [[ hi Normal guibg=#101020 ]]
  else
    vim.cmd [[ hi PmenuSel guifg=#e6e6e6 ]]
  end
end

local function set_background()
  local handle = io.popen('~/bin/background')
  local result = handle:read('*a')
  handle:close()
  result = result:gsub('%s+', '')
  if result == 'light' or result == 'dark' then
    vim.opt.background = result
    custom_one()
  end
end

vim.api.nvim_create_autocmd('OptionSet', {
    pattern = 'background',
    callback = custom_one,
})

vim.cmd [[ colorscheme one ]]
set_background()
vim.keymap.set("n", "<F13>", set_background, { noremap = true, silent = true })
vim.o.cursorline = true
vim.o.ignorecase = true
vim.o.smartcase = true

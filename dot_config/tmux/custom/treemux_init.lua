---@diagnostic disable: undefined-global
---@diagnostic disable: missing-fields
-- Neovim init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Remove the white status bar below
vim.o.laststatus = 0
vim.o.ruler = false

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

require("lazy").setup {
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    init = function()
      vim.cmd.colorscheme 'tokyonight-night'
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
  {
    'rcarriga/nvim-notify',
    config = function()
      require('notify').setup {
        render = 'compact',
        stages = 'static',
        top_down = false,
        timeout = 2000,
      }
      vim.notify = require 'notify'
    end,
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    config = function()
      require('neo-tree').setup {
        sources = {
          'filesystem',
          'git_status',
        },
        source_selector = {
          sources = {
            { source = 'filesystem' },
            { source = 'git_status' },
          },
          winbar = true,
          separator = '|',
          tabs_layout = 'active',
        },
        close_if_last_window = true,
        enable_git_status = true,
        enable_diagnostics = false,
        sort_case_insensitive = false,
        sort_function = nil,
        default_component_configs = {
          container = {
            enable_character_fade = false,
          },
          indent = {
            indent_size = 2,
            padding = 0,
            with_markers = true,
            indent_marker = '│',
            last_indent_marker = '└',
            highlight = 'NeoTreeIndentMarker',
            with_expanders = nil,
            expander_collapsed = '',
            expander_expanded = '',
            expander_highlight = 'NeoTreeExpander',
          },
          icon = {
            folder_closed = '',
            folder_open = '󰝰',
            folder_empty = '',
            default = '*',
            highlight = 'NeoTreeFileIcon',
          },
          modified = {
            symbol = '[+]',
            highlight = 'NeoTreeModified',
          },
          name = {
            trailing_slash = false,
            use_git_status_colors = true,
            highlight = 'NeoTreeFileName',
          },
          git_status = {
            symbols = {
              added = '',
              modified = '',
              deleted = '✖',
              renamed = '󰁕',
              untracked = '',
              ignored = '',
              unstaged = '!',
              staged = '󰐕',
              conflict = '',
            },
          },
          file_size = {
            enabled = true,
            required_width = 64,
          },
          type = {
            enabled = true,
            required_width = 122,
          },
          last_modified = {
            enabled = true,
            required_width = 88,
          },
          created = {
            enabled = true,
            required_width = 110,
          },
          symlink_target = {
            enabled = true,
          },
        },
        commands = {
          alfred = function(state)
            local node = state.tree:get_node()
            local alfred = vim.fn.exepath 'alfred'
            if alfred == '' then
              vim.notify('alfred not found', vim.log.levels.ERROR)
              return
            end
            vim.fn.jobstart { alfred, node.path }
          end,
          add_to_alfred = function(state)
            local node = state.tree:get_node()
            local altr = vim.fn.exepath 'altr'
            if altr == '' then
              vim.notify('altr not found', vim.log.levels.ERROR)
              return
            end
            vim.fn.jobstart { altr, '-w', 'com.nyako520.syspre', '-t', 'buffer', '-a', node.path }
          end,
          add_to_alfred_visual = function(_, nodes)
            local altr = vim.fn.exepath 'altr'
            if altr == '' then
              vim.notify('altr not found', vim.log.levels.ERROR)
              return
            end
            local args = { altr, '-w', 'com.nyako520.syspre', '-t', 'buffer', '-a', '-' }
            vim.list_extend(
              args,
              vim.tbl_map(function(node)
                return node.path
              end, nodes)
            )
            vim.fn.jobstart(args)
          end,
          toggle_open = function(state)
            local cmd = require("neo-tree.sources.common.commands")
            local node = state.tree:get_node()
            if node:has_children() then
              cmd.toggle_node(state)
            elseif node.type == "directory" then
              local _, e = pcall(require("neo-tree.sources.filesystem").toggle_directory, state)
              if e then
                vim.notify(e, vim.log.levels.ERROR)
              end
            else
              require('neo-tree').config.commands.open_in_tmux(state)
            end
          end,
          show_preview = function(state)
            local node = state.tree:get_node()
            local cmd = string.format("%s %s | less -R", vim.fn.exepath("fzf-preview"), vim.fn.shellescape(node.path))
            vim.fn.jobstart({"tmux", "popup", "-E", "-w", "75%", "-h", "90%", "-x", "30%", "-e", "TMUX_POPUP=1", cmd})
          end,
          fzf = function(state)
            local root = vim.fn.getcwd()
            vim.fn.jobstart({"fd", ".", ".", "-tf"}, {
              cwd = root,
              on_stdout = function(_, data, _)
                if data and #data[1] > 0 then
                  local chan = vim.fn.jobstart({"fzf", "--tmux", "center,75%,90%", "--preview", "fzf-preview {}", "--preview-window", "up,60%"}, {
                    stdin = 'pipe',
                    on_stdout = function(_, d, _)
                      if d and #d[1] > 0 then
                        local path = vim.fn.fnamemodify(d[1], ":p")
                        require("neo-tree.sources.filesystem")._navigate_internal(state, nil, path)
                      end
                    end
                  })
                  vim.fn.chansend(chan, table.concat(data, '\n'))
                  vim.fn.chanclose(chan, 'stdin')
                end
              end
            })
          end,
          autojump = function()
            local _z = ":reload:zoxide query {q} -l --exclude '${PWD}' | awk '{ if (!seen[tolower()]++) print }' || true"
            vim.fn.jobstart({"fzf", "--bind", "start".._z, "--bind", "change".._z, "--disabled", "--preview", "fzf-preview {}", "--preview-window", "up,60%", "--tmux", "center,75%,90%"}, {
              on_stdout = function(_, data, _)
                if data and #data[1] > 0 then
                  vim.cmd("edit " .. data[1])
                end
              end
            })
          end,
          open_in_tmux = function(state, target)
            local node = state._node or state.tree:get_node()
            if target == 't' then
              local cmd = { 'tmux', 'new-window' }
              if node.type == "file" then
                table.insert(cmd, "nvim "..vim.fn.shellescape(node.path))
              else
                table.insert(cmd, "-c")
                table.insert(cmd, node.path)
              end
              vim.fn.jobstart(cmd)
              return
            end
            local pane = "{last}"
            if not target then
              local p = vim.fn.system("tmux display -p '#{pane_index}'")
              if vim.v.count > 0 and vim.v.count ~= tonumber(p) then
                pane = tostring(vim.v.count)
              end
            end
            if target == "s" or target == "v" then
              vim.fn.jobstart({ 'tmux', 'selectp', '-t', pane })
              local cmd = { 'tmux', 'splitw' }
              if target == "s" then
                table.insert(cmd, '-v')
              else
                table.insert(cmd, '-h')
              end
              if node.type == "file" then
                table.insert(cmd, "nvim "..vim.fn.shellescape(node.path))
              else
                table.insert(cmd, "-c")
                table.insert(cmd, node.path)
              end
              vim.fn.jobstart(cmd)
              return
            end
            local result = vim.fn.system('tmux display -p -t "'..pane..'" "#{pane_current_command} #{pane_pid}"')
            vim.fn.jobstart({ 'tmux', 'selectp', '-t', pane })
            local proc, pid = result:match("^(%S+) (%d+)")
            if node.type == "file" then
              if proc == "nvim" then
                local command = 'pid=' .. pid .. [[;
                until (ps -o command= -p $pid | grep -Eq "^nvim --embed"); do
                  pid=$(pgrep -P $pid 2> /dev/null)
                  [ -z "$pid" ] && exit
                done
                nvr --serverlist | grep $pid ]]
                local socket = vim.fn.trim(vim.fn.system(command))
                if socket ~= "" then
                  vim.fn.jobstart({"nvim", "--server", socket, "--remote", node.path})
                  return
                end
              elseif proc == "zsh" then
                vim.fn.jobstart({"tmux", "send", "nvim "..vim.fn.shellescape(node.path), "Enter"})
              else
                vim.fn.jobstart({"tmux", "splitw", "-v", "nvim "..vim.fn.shellescape(node.path), "Enter"})
              end
            else
              if proc == "zsh" then
                vim.fn.jobstart({"tmux", "send", "cd "..vim.fn.shellescape(node.path), "Enter"})
              else
                vim.fn.jobstart({"tmux", "splitw", "-v", "-c", node.path})
              end
            end
          end,
          send_to_tmux = function(state, run)
            local tx = {"tmux", "selectp", "-t"}
            local mode = vim.api.nvim_get_mode().mode
            local text
            if mode == "n" then
              text = state.tree:get_node().path
            else
              vim.cmd 'normal! y'
              text = vim.fn.getreg '"'
            end
            local chan = vim.fn.jobstart({'tmux', 'loadb', '-'}, {stdin = 'pipe'})
            vim.fn.chansend(chan, text)
            vim.fn.chanclose(chan, 'stdin')
            local p = vim.fn.system("tmux display -p '#{pane_index}'")
            if vim.v.count > 0 and vim.v.count ~= tonumber(p) then
              table.insert(tx, tostring(vim.v.count))
            else
              table.insert(tx, "{last}")
            end
            vim.list_extend(tx, { ";", "pasteb", "-d" })
            if run then
              vim.list_extend(tx, { ";", "send", "Enter", ";", "selectp", "-l" })
            end
            vim.fn.jobstart(tx)
          end,
        },
        window = {
          position = 'current',
          width = "100%",
          mapping_options = {
            noremap = true,
            nowait = true,
          },
          mappings = {
            ['oc'] = '',
            ['od'] = '',
            ['og'] = '',
            ['om'] = '',
            ['on'] = '',
            ['os'] = '',
            ['ot'] = '',
            ['w'] = '',
            ['o'] = {
              'open_in_tmux',
              noremap = false,
              nowait = true,
            },
            ['O'] = {
              function(state)
                local path = state.tree:get_node().path
                vim.ui.open(path)
              end,
              desc = 'system_open',
            },
            ['<2-LeftMouse>'] = 'open_in_tmux',
            ['l'] = 'toggle_open',
            ['<esc>'] = 'cancel',
            ['<tab>'] = {
              function(state)
                local node = state.tree:get_node()
                vim.fn.jobstart { 'qlmanage', '-p', node.path }
              end,
            },
            ['<C-s>'] = {
              function(state)
                require('neo-tree').config.commands.open_in_tmux(state, 's')
              end,
              desc = 'open_in_split',
            },
            ['<C-v>'] = {
              function(state)
                require('neo-tree').config.commands.open_in_tmux(state, 'v')
              end,
              desc = 'open_in_vsplit',
            },
            ['s'] = '',
            ['<C-t>'] = {
              function(state)
                require('neo-tree').config.commands.open_in_tmux(state, 't')
              end,
              desc = 'open_in_new_window',
            },
            ['<space>'] = '',
            -- ['<cr>'] = 'open_drop',
            -- ['t'] = 'open_tab_drop',
            ['P'] = 'show_preview',
            ['h'] = {
              function(state)
                local node = state.tree:get_node()
                require('neo-tree.ui.renderer').focus_node(state, node:get_parent_id(), true)
              end,
              desc = 'find_parent',
            },
            ['H'] = 'close_node',
            ['J'] = {
              function(state)
                local node = state.tree:get_node()
                local siblings = state.tree:get_nodes(node:get_parent_id())
                for i, v in ipairs(siblings) do
                  if v.name == node.name then
                    local next_node = siblings[i + 1] or siblings[1]
                    require('neo-tree.ui.renderer').focus_node(state, next_node:get_id(), true)
                    return
                  end
                end
              end,
              desc = 'next_sibling',
            },
            ['K'] = {
              function(state)
                local node = state.tree:get_node()
                local siblings = state.tree:get_nodes(node:get_parent_id())
                for i, v in ipairs(siblings) do
                  if v.name == node.name then
                    local next_node = siblings[i - 1] or siblings[#siblings]
                    require('neo-tree.ui.renderer').focus_node(state, next_node:get_id(), true)
                    return
                  end
                end
              end,
              desc = 'previous_sibling',
            },
            ['{'] = 'close_all_nodes',
            ['}'] = 'expand_all_nodes',
            ['N'] = {
              'add',
              config = {
                show_path = 'none',
              },
            },
            ['d'] = 'delete',
            ['r'] = 'rename',
            ['a'] = 'alfred',
            ['='] = 'add_to_alfred',
            ['x'] = 'cut_to_clipboard',
            ['p'] = 'paste_from_clipboard',
            ['c'] = 'copy',
            ['C'] = 'copy_to_clipboard',
            ['m'] = 'move',
            ['q'] = function()
              vim.cmd 'quitall!'
            end,
            ['<f1>'] = function()
              vim.cmd 'quitall!'
            end,
            ['R'] = 'refresh',
            ['?'] = 'show_help',
            ['<'] = 'prev_source',
            ['>'] = 'next_source',
            ['I'] = 'show_file_details',
            ['<C-u>'] = '',
            ['<C-d>'] = '',
            ['y'] = {
              function(state)
                local path = vim.fn.fnamemodify(state.tree:get_node().path, ':.')
                vim.fn.setreg('*', path)
                vim.notify('Yanked path to clipboard: ' .. path)
              end,
              desc = 'yank file path',
            },
            ['\\y'] = {
              function(state)
                local path = state.tree:get_node().path
                local chan = vim.fn.jobstart({'tmux', 'loadb', '-'}, {stdin = 'pipe'})
                vim.fn.chansend(chan, path)
                vim.fn.chanclose(chan, 'stdin')
                vim.notify('Yanked path to tmux buffer: ' .. path)
              end,
              desc = 'yank file path to tmux',
            },
            ['!'] = {
              function(state)
                local path = state.tree:get_node().path
                path = vim.fn.shellescape(path)
                vim.api.nvim_feedkeys(': ' .. path, 'n', true)
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Home>', true, true, true), 'n', true)
                vim.api.nvim_feedkeys('!', 'n', true)
              end,
              desc = 'run command with path',
            },
            ['z'] = 'toggle_auto_expand_width',
            ['\\f'] = 'fzf',
            ['\\g'] = 'autojump',
            ['_'] = 'send_to_tmux',
            ['-'] = {
              function(state)
                require('neo-tree').config.commands.send_to_tmux(state, true)
              end,
            },
          },
        },
        nesting_rules = {},
        filesystem = {
          filtered_items = {
            visible = false,
            hide_dotfiles = false,
            hide_gitignored = false,
            hide_hidden = true,
            hide_by_name = {
            },
            hide_by_pattern = {
            },
            always_show = {
            },
            always_show_by_pattern = {
            },
            never_show = {
              '.DS_Store',
            },
            never_show_by_pattern = {
            },
          },
          follow_current_file = {
            enabled = true,
            leave_dirs_open = false,
          },
          group_empty_dirs = true,
          hijack_netrw_behavior = 'open_current',
          use_libuv_file_watcher = false,
          window = {
            mappings = {
              ['u'] = 'navigate_up',
              ['<cr>'] = 'set_root',
              ['.'] = {
                function(state)
                  state.filtered_items.hide_dotfiles = not state.filtered_items.hide_dotfiles
                  require('neo-tree.sources.filesystem')._navigate_internal(state, nil, nil, nil, false)
                end,
                desc = 'toggle_hidden',
              },
              ['gi'] = {
                function(state)
                  state.filtered_items.hide_gitignored = not state.filtered_items.hide_gitignored
                  require('neo-tree.sources.filesystem')._navigate_internal(state, nil, nil, nil, false)
                end,
                desc = 'toggle_gitignore',
              },
              ['/'] = 'fuzzy_finder',
              -- ['D'] = 'fuzzy_finder_directory',
              ['#'] = 'fuzzy_sorter', -- fuzzy sorting using the fzy algorithm
              -- ['D'] = 'fuzzy_sorter_directory',
              -- ['f'] = 'filter_on_submit',
              ['<c-r>'] = 'clear_filter',
              ['[c'] = 'prev_git_modified',
              [']c'] = 'next_git_modified',
              ['S'] = { 'show_help', nowait = false, config = { title = 'Sort by', prefix_key = 'S' } },
              ['Sc'] = { 'order_by_created', nowait = false },
              ['Sd'] = { 'order_by_diagnostics', nowait = false },
              ['Sg'] = { 'order_by_git_status', nowait = false },
              ['Sm'] = { 'order_by_modified', nowait = false },
              ['Sa'] = { 'order_by_name', nowait = false },
              ['Ss'] = { 'order_by_size', nowait = false },
              ['St'] = { 'order_by_type', nowait = false },
              -- ['<key>'] = function(state) ... end,
            },
            fuzzy_finder_mappings = {
              ['<down>'] = 'move_cursor_down',
              ['<C-n>'] = 'move_cursor_down',
              ['<up>'] = 'move_cursor_up',
              ['<C-p>'] = 'move_cursor_up',
            },
          },
        },
        git_status = {
          window = {
            mappings = {
              ['gA'] = 'git_add_all',
              ['gu'] = 'git_unstage_file',
              ['ga'] = 'git_add_file',
              ['gr'] = 'git_revert_file',
              ['gc'] = 'git_commit',
              ['gp'] = 'git_push',
              ['gg'] = 'git_commit_and_push',
              ['S'] = { 'show_help', nowait = false, config = { title = 'Sort by', prefix_key = 'S' } },
              ['Sc'] = { 'order_by_created', nowait = false },
              ['Sd'] = { 'order_by_diagnostics', nowait = false },
              ['Sm'] = { 'order_by_modified', nowait = false },
              ['Sa'] = { 'order_by_name', nowait = false },
              ['Ss'] = { 'order_by_size', nowait = false },
              ['St'] = { 'order_by_type', nowait = false },
            },
          },
        },
        event_handlers = {
          {
            event = 'file_opened',
            handler = function(file)
              require('neo-tree').config.commands.open_in_tmux({ _node = { type = 'file', path = file } })
              vim.cmd 'quit'
            end,
          },
        },
      }
      vim.keymap.set('x', '-', function() require('neo-tree').config.commands.send_to_tmux(nil, true) end, { noremap = false })
      vim.keymap.set('x', '_', require('neo-tree').config.commands.send_to_tmux, { noremap = false })
      vim.cmd.hi 'NeoTreeSymbolicLinkTarget gui=italic'
    end,
  },
  {
    'mrjones2014/smart-splits.nvim',
    keys = {
      { '<c-h>', '<cmd>SmartCursorMoveLeft<cr>' },
      { '<c-j>', '<cmd>SmartCursorMoveDown<cr>' },
      { '<c-k>', '<cmd>SmartCursorMoveUp<cr>' },
      { '<c-l>', '<cmd>SmartCursorMoveRight<cr>' },
    },
  },
  {
    'folke/flash.nvim',
    opts = {
      jump = {
        autojump = true,
      },
    },
    keys = {
      'f',
      'F',
      't',
      'T',
      {
        'S',
        mode = { 'n', 'o' },
        function()
          require('flash').treesitter()
        end,
        desc = 'Flash Treesitter',
      },
      {
        'r',
        mode = 'o',
        function()
          require('flash').remote()
        end,
        desc = 'Remote Flash',
      },
      {
        'R',
        mode = { 'o', 'x' },
        function()
          require('flash').treesitter_search()
        end,
        desc = 'Treesitter Search',
      },
      {
        '<C-s>',
        mode = { 'c' },
        function()
          require('flash').toggle()
        end,
        desc = 'Toggle Flash Search',
      },
    },
  },
  {
    'rainzm/flash-zh.nvim',
    event = 'VeryLazy',
    dependencies = 'folke/flash.nvim',
    keys = {
      {
        's',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash-zh').jump { chinese_only = false }
        end,
        desc = 'Flash',
      },
      {
        'z',
        mode = { 'o' },
        function()
          require('flash-zh').jump { chinese_only = false }
        end,
        desc = 'Flash',
      },
    },
  }
}

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'sync yanked text to tmux buffer',
  group = vim.api.nvim_create_augroup('yank', { clear = true }),
  callback = function()
    local chan = vim.fn.jobstart({'tmux', 'loadb', '-'}, {stdin = 'pipe'})
    vim.fn.chansend(chan, vim.fn.trim(vim.fn.getreg('"')))
    vim.fn.chanclose(chan, 'stdin')
  end,
})

vim.keymap.set({ 'n', 'x' }, '<A-k>', '12k', { noremap = true })
vim.keymap.set({ 'n', 'x' }, '<A-j>', '12j', { noremap = true })

vim.fn.jobstart({'background'}, {
  on_stdout = function(_, data, _)
    if data and #data[1] > 0 then
      local bg = vim.fn.trim(data[1])
      if bg == 'light' or bg == 'dark' then
        vim.opt.background = bg
      end
    end
  end
})
vim.o.cursorline = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.fillchars = "eob: "

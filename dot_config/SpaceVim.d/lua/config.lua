-- vim.g.indent_blankline_use_treesitter = true
-- vim.g.indent_blankline_context_char = '│'
-- vim.g.indent_blankline_show_current_context = true

vim.cmd('luafile ' .. os.getenv("XDG_CONFIG_HOME") .. '/SpaceVim.d/lua/one-custom.lua')

local first_insert = 1
local function firstInsertEnter()
  if first_insert == 1 then
    vim.cmd('luafile ' .. os.getenv("XDG_CONFIG_HOME") .. '/SpaceVim.d/lua/nvim-cmp.lua')
    vim.api.nvim_set_keymap('n', '/', '<C-/>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '?', '<C-?>', { noremap = true, silent = true })
    first_insert = 0
  end
end

vim.api.nvim_create_augroup('FirstInsertEnter', { clear = true })
vim.api.nvim_create_autocmd('InsertEnter', {
  group = 'FirstInsertEnter',
  callback = firstInsertEnter,
})

vim.api.nvim_create_augroup('BackgroundChange', { clear = true })
vim.api.nvim_create_autocmd('OptionSet', {
  group = 'BackgroundChange',
  pattern = 'background',
  callback = function() CustomOne() end,
})

vim.api.nvim_create_augroup('NoBackup', { clear = true })
vim.api.nvim_create_autocmd('BufWrite', {
  group = 'NoBackup',
  pattern = { '/private/tmp/crontab.*', '/private/etc/pw.*' },
  callback = function()
    vim.opt.nowritebackup = true
    vim.opt.backup = false
  end,
})

vim.api.nvim_create_augroup('Terminal', { clear = true })
vim.api.nvim_create_autocmd('TermOpen', {
  group = 'Terminal',
  pattern = '*',
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})

if vim.fn.exists(':NERDTree') == 2 then
  vim.cmd('luafile ' .. os.getenv("XDG_CONFIG_HOME") .. '/SpaceVim.d/lua/nerdtree-config.lua')
end

if vim.fn.exists(':Telescope') == 2 then
  vim.api.nvim_create_augroup('TelescopeConfig', { clear = true })
  vim.api.nvim_create_autocmd('User', {
    group = 'TelescopeConfig',
    pattern = 'TelescopePreviewerLoaded',
    callback = function()
      vim.cmd('luafile ' .. os.getenv("XDG_CONFIG_HOME") .. '/SpaceVim.d/lua/telescope-config.lua')
    end,
  })
end

-- markdown settings
vim.api.nvim_create_augroup('Markdown', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = 'Markdown',
  pattern = 'markdown',
  callback = function()
    vim.opt_local.wrapmargin = 2
    vim.opt_local.matchpairs:append('（:）,「:」')
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.spell = true
  end,
})

if vim.fn.exists(':Copilot') == 2 then
  vim.api.nvim_create_augroup('Copilot', { clear = true })
  vim.api.nvim_create_autocmd('BufNew', {
    group = 'Copilot',
    pattern = '*',
    callback = function()
      vim.b.copilot_workspace_folders = { vim.fn.getcwd() }
    end,
  })
end

vim.opt.mouse = 'nicrv'
vim.opt.backspace = { 'indent', 'eol', 'start' }
vim.opt.foldmethod = 'manual'
vim.opt.encoding = 'utf-8'
vim.opt.fileencodings = { 'utf-8', 'gb18030', 'default' }
vim.opt.fillchars = { vert = '│', fold = '·', eob = ' ' }
vim.opt.scrolloff = 5
vim.opt.sidescrolloff = 15
vim.opt.listchars:append({ precedes = '<', extends = '>' })
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.termguicolors = true

-- Function to set tab and shiftwidth
local function Tab(len)
  len = len == "" and 4 or len
  vim.opt.shiftwidth = tonumber(len)
  vim.opt.tabstop = tonumber(len)
end

-- Function to retab the buffer
local function Retab(before, after)
  if before ~= "" then
    vim.opt_local.shiftwidth = tonumber(before)
    vim.opt_local.tabstop = tonumber(before)
  end
  vim.opt_local.expandtab = false
  vim.cmd("retab!")
  
  local len = after == "" and 2 or tonumber(after)
  vim.opt_local.shiftwidth = len
  vim.opt_local.tabstop = len
  
  if after ~= "" then
    vim.opt_local.expandtab = true
    vim.cmd("retab")
  end
end

-- Function to get the selected text in visual mode
local function GetSelection()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line = start_pos[2]
  local start_col = start_pos[3]
  local end_line = end_pos[2]
  local end_col = end_pos[3]
  
  local selected_text = ""
  if start_line == end_line then
    selected_text = vim.fn.getline(start_line):sub(start_col, end_col)
    return selected_text
  end
  
  for line = start_line, end_line do
    local line_text = ""
    if line == start_line then
      line_text = vim.fn.getline(line):sub(start_col)
    elseif line == end_line then
      line_text = vim.fn.getline(line):sub(1, end_col)
    else
      line_text = vim.fn.getline(line)
    end
    selected_text = selected_text .. line_text
    if line ~= end_line then
      selected_text = selected_text .. "\n"
    end
  end
  
  return selected_text
end

if os.getenv("TMUX") and os.getenv("TMUX") ~= "" then
  -- Function to yank selection to tmux
  function YankToTmux()
    local selected_text = GetSelection()
    local tmux_sess = vim.fn.system('tmux display -p "#S"')
    vim.fn.setreg("o", selected_text)
    local cmd = string.format('~/.local/bin/altr -w com.nyako520.tmux -t reg2buf -v reg=o -v "socket=%s" -v sess=%s', vim.v.servername, tmux_sess)
    vim.cmd('silent !' .. cmd)
  end

  -- Function to paste in tmux pane
  function PasteInTmux(pane, run)
    local selected_text = GetSelection()
    local tmux_pane = vim.fn.system('tmux display -p "#S:#{window_index}"')
    tmux_pane = tmux_pane:gsub('\n', '') .. '.' .. pane
    vim.fn.setreg("o", selected_text)
    local cmd = string.format('~/.local/bin/altr -w com.nyako520.tmux -t vim2tmux -v reg=o -v "socket=%s" -v "pane=%s" -v run=%s', vim.v.servername, tmux_pane, run)
    vim.cmd('silent !' .. cmd)
  end

  -- Function to paste from tmux
  function PasteFromTmux(v)
    local tmux_buffer = vim.fn.system('tmux show-buffer')
    vim.fn.setreg("o", tmux_buffer)
    if v == 1 then
      vim.cmd('normal! gv"op')
    else
      vim.cmd('normal! "op')
    end
  end

  -- Mappings
  vim.api.nvim_set_keymap('x', '<Space>[', ':<C-u>lua YankToTmux()<CR>', { silent = true })
  vim.api.nvim_set_keymap('n', '<Space>]', ':<C-u>lua PasteFromTmux(0)<CR>', { silent = true })
  vim.api.nvim_set_keymap('x', '<Space>]', ':<C-u>lua PasteFromTmux(1)<CR>', { silent = true })
  vim.api.nvim_set_keymap('i', '<C-]>', '<ESC>:<C-u>lua PasteFromTmux(0)<CR>', { silent = true })
  vim.api.nvim_set_keymap('x', '<Space>-', ':<C-u>lua PasteInTmux(vim.v.count, 1)<CR>', { silent = true })
  vim.api.nvim_set_keymap('x', '<Space>_', ':<C-u>lua PasteInTmux(vim.v.count, 0)<CR>', { silent = true })
end

-- Function to interact with chezmoi
local function Chezmoi(action)
  local p = vim.fn.shellescape(vim.fn.expand('%:p'))

  if action == 'add' or action == 'a' then
    local o = vim.fn.system('chezmoi -n add ' .. p)
    if vim.v.shell_error ~= 0 then
      vim.api.nvim_err_writeln(o)
      return
    end
    vim.cmd('silent !chezmoi add ' .. p)
    print('File added to chezmoi')
    vim.cmd('redraw')

  elseif action == 'aa' then
    vim.fn.system("chezmoi status -i files -p absolute | grep -vE '^D' | choose 1.. | xargs -I _ chezmoi add '_'")
    vim.fn.system("chezmoi status -i files -p absolute | grep -E '^D' | choose 1.. | xargs -I _ chezmoi forget --force '_'")
    if vim.v.shell_error == 0 then
      print('All changes added to chezmoi')
      vim.cmd('redraw')
    end

  elseif action == 'restore' or action == 'r' then
    local o = vim.fn.system('chezmoi -n status ' .. p)
    if vim.v.shell_error ~= 0 then
      vim.api.nvim_err_writeln(o)
      return
    end
    vim.cmd('silent !chezmoi apply --force ' .. p)
    print('File restored')
    vim.cmd('redraw')

  elseif action == 'diff' or action == 'd' then
    local o = vim.fn.system('chezmoi source-path ' .. p)
    if vim.v.shell_error ~= 0 then
      vim.api.nvim_err_writeln(o)
      return
    end
    vim.cmd('vsp ' .. o)
    vim.cmd('windo diffthis')

  elseif action == 'status' or action == 's' then
    print(vim.fn.system('chezmoi status ' .. p))

  elseif action == 'sa' then
    print(vim.fn.system('chezmoi status'))
  end
end

-- Function to paste and keep the current register
local function PasteAndKeepReg()
  local reg = vim.fn.getreg('"')
  local regtype = vim.fn.getregtype('"')
  vim.cmd('normal! gvp')
  vim.fn.setreg('"', reg, regtype)
end

-- Function to toggle diff mode
local function ToggleDiff()
  if vim.fn.exists(':NERDTree') == 2 then
    vim.cmd('NERDTreeClose')
  end
  if vim.fn.winnr('$') == 1 then
    return
  end
  if vim.wo.diff then
    vim.cmd('windo diffoff')
  else
    vim.cmd('windo diffthis')
  end
end

-- Set ignorecase and smartcase for searching
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Set wildmode for command-line completion
vim.opt.wildmode = {'longest:list', 'full'}

-- Enable filetype plugins and indenting
vim.cmd('filetype plugin indent on')

-- Set split behavior
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Neovim specific configs
if vim.fn.has('nvim') == 1 then
  -- Add any Neovim-specific configuration here
end

-- Terminal app specific configs
if vim.fn.getenv('COLORTERM') == "truecolor" then
  vim.opt.termguicolors = true
  vim.g.spacevim_enable_guicolors = 1
else
  vim.opt.termguicolors = false
  vim.g.spacevim_enable_guicolors = 0
end

-- Command-line mappings
vim.api.nvim_set_keymap('c', ';d', '<C-r>=expand("%:p:h") . "/"<CR>', { noremap = true })
vim.api.nvim_set_keymap('c', ';f', '<C-r>=expand("%")<CR>', { noremap = true })
vim.api.nvim_set_keymap('c', ';/\\', '\\{-}', { noremap = true })

-- Commands
local script_path = debug.getinfo(1, 'S').source:sub(2)
vim.api.nvim_create_user_command('EF', function() vim.cmd('tabe ' .. script_path) end, {})
vim.api.nvim_create_user_command('ER', function() vim.cmd('source ' .. script_path) end, {})
vim.api.nvim_create_user_command('P', function() vim.cmd('tabe ' .. vim.fn.getreg('+')) end, {})
vim.api.nvim_create_user_command('AF', function() vim.cmd('!alfred ' .. vim.fn.shellescape(vim.fn.expand("%:p"), 1)) end, {})
vim.api.nvim_create_user_command('VS', function() vim.cmd('!code ' .. vim.fn.shellescape(vim.fn.getcwd()) .. ' && sleep 1 && code -g ' .. vim.fn.shellescape(vim.fn.expand("%:p"))) end, {})
vim.api.nvim_create_user_command('TA', function(args) Tab(tonumber(args.args)) end, { nargs = 1 })
vim.api.nvim_create_user_command('TR', function(args) Retab(tonumber(args.args), 2) end, { nargs = 1 })
vim.api.nvim_create_user_command('Se', function(args) SpaceVim.plugins.iedit.start({ expr = args.args, selectall = 1 }) end, { nargs = '+' })
vim.api.nvim_create_user_command('SE', function(args) SpaceVim.plugins.iedit.start({ expr = args.args, selectall = 0 }) end, { nargs = '+' })
vim.api.nvim_create_user_command('Sw', function(args) SpaceVim.plugins.iedit.start({ word = args.args, selectall = 1 }) end, { nargs = '+' })
vim.api.nvim_create_user_command('SW', function(args) SpaceVim.plugins.iedit.start({ word = args.args, selectall = 0 }) end, { nargs = '+' })
vim.api.nvim_create_user_command('SL', function(args) vim.bo.spelllang = args.args end, { nargs = 1 })
vim.api.nvim_create_user_command('CM', function(args) Chezmoi(args.args) end, { nargs = '*' })
vim.api.nvim_create_user_command('TES', '20sp +term', {})
vim.api.nvim_create_user_command('TER', '65vsp +term', {})
vim.api.nvim_create_user_command('PER', '!chmod +x "%:p"', {})
vim.api.nvim_create_user_command('DF', ToggleDiff, {})

-- Normal mode mappings
vim.api.nvim_set_keymap('n', '<Up>', 'gk', { noremap = true })
vim.api.nvim_set_keymap('n', '<Down>', 'gj', { noremap = true })
vim.api.nvim_set_keymap('n', '<A-k>', '12k', { noremap = true })
vim.api.nvim_set_keymap('n', '<A-j>', '12j', { noremap = true })
vim.api.nvim_set_keymap('n', 'gj', '[e', { noremap = true })
vim.api.nvim_set_keymap('n', 'gk', ']e', { noremap = true })
vim.api.nvim_set_keymap('n', 'g.', 'gi', { noremap = true })
vim.api.nvim_set_keymap('n', '<ESC>', ':nohl<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Space>x=', '=`]', { noremap = true })
vim.api.nvim_set_keymap('n', '<Space>w|', ':vsp<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<Space>fO', ':call system(\'open \' .. shellescape(expand("%:p")))<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<f1>', ':NERDTreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<f4>', ':TES<CR>', { noremap = true, silent = true })
vim.cmd [[silent! nunmap ma]]  -- Unmap 'ma'
vim.api.nvim_set_keymap('n', 'ml', ':BookmarkShowAll<CR>', { noremap = true, silent = true })

-- Visual mode mappings
vim.api.nvim_set_keymap('x', '<Up>', 'gk', { noremap = true })
vim.api.nvim_set_keymap('x', '<Down>', 'gj', { noremap = true })
vim.api.nvim_set_keymap('x', '<M-k>', '12k', { noremap = true })
vim.api.nvim_set_keymap('x', '<M-j>', '12j', { noremap = true })
vim.api.nvim_set_keymap('x', 'C', '"+y', { noremap = true })
vim.api.nvim_set_keymap('x', 'X', '"+x', { noremap = true })
vim.api.nvim_set_keymap('x', 'p', ':<C-u>call PasteAndKeepReg()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', '<CR>', '"oy<ESC>:call system(\'open \' .. shellescape(getreg(\'o\')))<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', 'gs', '"oy/<C-r>o<CR>', { noremap = true })
vim.api.nvim_set_keymap('x', 'g<CR>', '"os<CR><ESC>k:r!<C-r>o<CR>kJJ', { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', '<Space>se', '"1y:Se <C-r>1<CR><CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', '<Space>sE', '"1y:SE <C-r>1<CR><CR>', { noremap = true, silent = true })

-- Terminal mode mappings
vim.api.nvim_set_keymap('t', '<ESC>', '<C-\\><C-n>', { noremap = true })
vim.api.nvim_set_keymap('t', '<f4>', '<ESC>:q<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<C-J>', '<C-Down>', { noremap = true })
vim.api.nvim_set_keymap('t', '<C-K>', '<C-Up>', { noremap = true })
vim.api.nvim_set_keymap('t', '<C-H>', '<C-Left>', { noremap = true })
vim.api.nvim_set_keymap('t', '<C-L>', '<C-Right>', { noremap = true })
vim.api.nvim_set_keymap('t', '<A-Left>', '<A-b>', { noremap = true })
vim.api.nvim_set_keymap('t', '<A-Right>', '<A-f>', { noremap = true })

-- EasyMotion settings
vim.g.EasyMotion_verbose = 0
vim.g.EasyMotion_leader_key = ";"
vim.g.EasyMotion_skipfoldedline = 0
vim.g.EasyMotion_space_jump_first = 1
vim.g.EasyMotion_move_highlight = 0
vim.g.EasyMotion_use_migemo = 1
vim.g.EasyMotion_startofline = 0

-- EasyMotion mappings
vim.api.nvim_set_keymap('n', 's', '<Plug>(easymotion-fl2)', {})
vim.api.nvim_set_keymap('n', ';', '<Plug>(easymotion-prefix)', {})
vim.api.nvim_set_keymap('n', ';f', '<Plug>(easymotion-fl)', {})
vim.api.nvim_set_keymap('n', ';s', '<Plug>(easymotion-overwin-f2)', {})
vim.api.nvim_set_keymap('o', 'z', '<Plug>(easymotion-f2)', {})
vim.api.nvim_set_keymap('n', ';/\\', '<Plug>(easymotion-sn)', {})
vim.api.nvim_set_keymap('n', ';L', '<Plug>(easymotion-overwin-line)', {})
-- vim.api.nvim_set_keymap('n', ';.', '<Plug>(easymotion-repeat)', {})  -- Uncomment if you want to use this mapping
vim.api.nvim_set_keymap('n', ';;', '<Plug>(easymotion-next)', {})
vim.api.nvim_set_keymap('n', ';,', '<Plug>(easymotion-prev)', {})

-- Copilot dummy map
vim.api.nvim_set_keymap('i', '<Plug>(vimrc:copilot-dummy-map)', [[copilot#Accept("\<Tab>")]], { silent = true, expr = true, script = true })

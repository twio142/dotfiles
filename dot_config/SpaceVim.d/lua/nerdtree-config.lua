-- Set global variables
vim.g.NERDTreeBookmarksFile = os.getenv("XDG_STATE_HOME") .. "/nerdtree/bookmarks"
vim.g.NERDTreeSortOrder = { "\\/$", "*", "\\.swp$", "\\.bak$", "\\~$", "[[-timestamp]]" }
vim.g.NERDTreeDirArrowExpandable = ""
vim.g.NERDTreeDirArrowCollapsible = ""
vim.g.NERDTreeShowHidden = 1
vim.g.NERDTreeMinimalUI = 1
vim.g.NERDTreeAutoDeleteBuffer = 1

-- Define NERDTreeBookmark function
function NerdtreeBookmark(action)
  local key = vim.fn.nr2char(vim.fn.getchar())
  if action == "add" then
    vim.cmd("Bookmark " .. key)
  elseif action == "reveal" then
    vim.cmd("RevealBookmark " .. key)
  elseif action == "open" then
    vim.cmd("OpenBookmark " .. key)
  end
end

-- Set up autocommands for NERDTree
vim.api.nvim_create_augroup("NERDTree", { clear = true })

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = "NERDTree",
  pattern = "*",
  callback = function()
    if vim.o.buftype ~= "quickfix" and vim.fn.getcmdwintype() == "" then
      vim.cmd("silent NERDTreeMirror")
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = "NERDTree",
  pattern = "nerdtree",
  callback = function()
    vim.keymap.set("n", "<C-h>", ":TmuxNavigateLeft<CR>", { buffer = true, silent = true })
    vim.keymap.set("n", "<C-j>", ":TmuxNavigateDown<CR>", { buffer = true, silent = true })
    vim.keymap.set("n", "<C-k>", ":TmuxNavigateUp<CR>", { buffer = true, silent = true })
    vim.keymap.set("n", "<C-l>", ":TmuxNavigateRight<CR>", { buffer = true, silent = true })
    vim.keymap.set("n", "r", ":NERDTreeRefreshRoot<CR>", { buffer = true, silent = true })
    vim.keymap.set("n", "<C-r>", ":NERDTreeRefreshRoot<CR>", { buffer = true, silent = true })
    vim.keymap.set("n", "y", ":cal NERDTreeCopyPath()<CR>", { buffer = true, silent = true })
    vim.keymap.set("n", "<Tab>", ":cal NERDTreeQuickLook()<CR>", { buffer = true, silent = true })
    vim.keymap.set("n", "R", ":cal NERDTreeMoveNode()<CR>", { buffer = true, silent = true })
    vim.keymap.set("n", "M", ':cal nerdtree#ui_glue#invokeKeyMap("m")<CR>', { buffer = true, silent = true })
    vim.keymap.set("n", "mm", ':lua NerdtreeBookmark("add")<CR>', { buffer = true, silent = true })
    vim.keymap.set("n", "mf", ':lua NerdtreeBookmark("reveal")<CR>', { buffer = true, silent = true })
    vim.keymap.set("n", "mo", ':lua NerdtreeBookmark("open")<CR>', { buffer = true, silent = true })
    vim.keymap.set("n", "mc", ":ClearBookmarks<CR>", { buffer = true, silent = true })
    vim.keymap.set("n", "mC", ":ClearAllBookmarks<CR>", { buffer = true, silent = true })
    vim.keymap.set("n", "}", ':cal nerdtree#ui_glue#invokeKeyMap("O")<CR>', { buffer = true, silent = true })
    vim.keymap.set("n", "{", ':cal nerdtree#ui_glue#invokeKeyMap("X")<CR>', { buffer = true, silent = true })
  end,
})

vim.cmd([[
function! NERDTreeOpenInAlfred(node)
  call system("~/.local/bin/alfred " . shellescape(a:node.path.str(), 1))
endfunction

function! NERDTreeAddToAlfredBuffer(node)
  call system("~/.local/bin/altr -w com.nyako520.syspre -t buffer -a " . shellescape(a:node.path.str(), 1))
endfunction

function! NERDTreeSystemOpen(node)
  let cmd = has('mac') ? 'open' : 'xdg-open'
  call system(cmd . ' ' . shellescape(a:node.path.str(), 1))
endfunction

function! _NERDTreeRunCommand(node)
  call feedkeys(": ")
  call feedkeys(shellescape(a:node.path.str()), 't')
  call feedkeys("\<Home>")
  call feedkeys("!")
endfunction
]])

-- Define key mappings
local function map(key, callback, text, scope)
  vim.fn.NERDTreeAddKeyMap({ key = key, callback = callback, quickhelpText = text, scope = scope })
end

map("a", "NERDTreeOpenInAlfred", "open in Alfred", "Node")
map("=", "NERDTreeAddToAlfredBuffer", "add to Alfred buffer", "Node")
map("g<CR>", "NERDTreeSystemOpen", "open in system", "Node")
map(">", "NERDTreeRunCommand", "run command", "Node")

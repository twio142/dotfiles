local cmp = require 'cmp'

local feedkey = function(key, mode)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local function smart_tab(fallback)
	if vim.fn['neosnippet#expandable_or_jumpable']() == 1 then
		feedkey('<plug>(neosnippet_expand_or_jump)', '')
	elseif cmp.visible() then
		cmp.select_next_item()
	else
		fallback()
	end
end

cmp.setup({
	mapping = {
		['<Tab>'] = cmp.mapping(function(fallback)
			vim.api.nvim_feedkeys(vim.fn['copilot#Accept'](vim.api.nvim_replace_termcodes('<Tab>', true, true, true)), 'n', true)
		end),
		['<C-n>'] = smart_tab,
	},
	experimental = {
		ghost_text = false -- this feature conflicts with copilot.vim's preview.
	},
})

local dict = require'cmp_dictionary'
dict.switcher({
	filetype = {
		markdown = '/usr/share/dict/words',
	},
-- filepath = {
-- ['.*xmake.lua'] = { '/path/to/xmake.dict', '/path/to/lua.dict' },
-- ['%.tmux.*%.conf'] = { '/path/to/js.dict', '/path/to/js2.dict' },
-- },
-- spelllang = {
-- de = '/path/to/de.dict',
-- },
})

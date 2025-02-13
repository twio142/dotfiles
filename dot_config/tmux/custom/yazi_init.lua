vim.o.cmdheight = 0
vim.o.laststatus = 0
vim.o.shadafile = "NONE"
vim.o.termguicolors = true

local fg
vim.fn.jobstart({ vim.fn.expand("~/.local/bin/background") }, {
	on_stdout = function(_, data, _)
		if fg then
			return
		end
		if data and #data[1] > 0 then
			local bg = vim.fn.trim(data[1])
			if bg == "light" then
				fg = "#000000"
			elseif bg == "dark" then
				fg = "#ffffff"
			end
		end
		vim.api.nvim_set_hl(0, "Normal", { fg = fg or "#999999", bg = "NONE", ctermbg = "NONE" })
	end,
})

vim.api.nvim_create_autocmd("BufEnter", {
	once = true,
	pattern = "*",
	callback = function()
		local path = vim.fn.argv()[1]
		path = (path and path ~= "") and path or vim.fn.getcwd()
		vim.cmd("startinsert")
		vim.fn.termopen({ "yazi", path }, {
			on_exit = function()
				vim.cmd("q")
			end,
		})
	end,
})
